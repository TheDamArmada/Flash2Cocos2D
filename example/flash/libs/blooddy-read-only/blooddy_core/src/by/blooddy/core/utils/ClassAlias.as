////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils {

	import flash.net.getClassByAlias;
	import flash.system.ApplicationDomain;
	import flash.utils.getDefinitionByName;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					16.04.2010 18:04:54
	 */
	public final class ClassAlias {

		//--------------------------------------------------------------------------
		//
		//  Class initialization
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static function registerBuiltinAliases():void {
			const classes:Array = new Array(
				'flash.display::DisplayObject',
					'flash.display::AVM1Movie',
					'flash.display::Bitmap',
					'flash.display::InteractiveObject',
						'flash.display::DisplayObjectContainer',
							'flash.display::Loader',
							'flash.display::Sprite',
								'flash.display::MovieClip',
								'flash.html::HTMLLoader',
							'flash.display::Stage',
							'flash.text.engine::TextLine',
						'flash.display::SimpleButton',
						'flash.text::TextField',
					'flash.display::Shape',
					'flash.media::Video'
			);
			const app:ApplicationDomain = ApplicationDomain.currentDomain;
			var c:Class;
			var r:WeakRef;
			var ns:String = AS3 + '::';
			for each ( var n:String in classes ) {
				if ( app.hasDefinition( n ) ) {
					c = app.getDefinition( n ) as Class;
					if ( c ) {
						r = new WeakRef( c );
						_HASH[ n ] =		r; // записываем оригинальное имя
						n = ClassUtils.parseClassName( n );
						_HASH[ n ] =		r; // записываем shortname
						_HASH[ ns + n ] =	r; // записываем nsname
					}
				}
			}
			// важное исключение
			_HASH[ '*' ] = new WeakRef( new Object() ); // new Object() должен сразу удалиться и возвращаться будет undefined
		}
		registerBuiltinAliases();

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _HASH:Object = new Object();

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function getClass(name:*):Class {
			if ( name is QName ) {
				name = name.toString();
			} else if ( !( name is String ) ) {
				throw new ArgumentError();
			}
			var result:Class;
			if ( name ) {
				if ( name in _HASH ) {
					result = ( _HASH[ name ] as WeakRef ).get();
					if ( !result ) {
						if ( name === '*' ) return undefined;
						delete _HASH[ name ];
					}
				}
				if ( !result ) {
					try {
						result = getDefinitionByName( name ) as Class;
					} catch ( e:* ) {
						try {
							result = getClassByAlias( name );
						} catch ( e:* ) {
						}
					}
					if ( result ) {
						_HASH[ name ] = new WeakRef( result );
					}
				}
			}
			return result;
		}

		public static function registerAlias(c:Class):void {
			$registerClassAlias( ClassUtils.getClassName( c ), c );
		}

		public static function registerQNameAlias(name:*, c:Class):void {
			if ( name is QName ) {
				name = name.toString();
			} else if ( !( name is String ) ) {
				throw new ArgumentError();
			}
			$registerClassAlias( name, c );
		}

		public static function registerNamespaceAlias(ns:*, c:Class):void {
			if ( ns is Namespace ) {
				ns = ( ns as Namespace ).uri;
			} else if ( ns is QName ) {
				ns = ( ns as QName ).uri;
			} else if ( !( ns is String ) ) {
				throw new ArgumentError();
			}
			ns = ( ns ? ns + '::' : '' ) + ClassUtils.getClassName( c );
			$registerClassAlias( ns, c );
		}

		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static function $registerClassAlias(name:String, c:Class):void {
			if ( name in _HASH && ( _HASH[ name ] as WeakRef ).get() === c ) return;
			_HASH[ name ] = new WeakRef( c );
		}

	}

}