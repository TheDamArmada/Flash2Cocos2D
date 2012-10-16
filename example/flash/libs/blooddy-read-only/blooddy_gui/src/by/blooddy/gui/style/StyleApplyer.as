////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.gui.style {

	import by.blooddy.code.css.definition.CSSRule;
	import by.blooddy.code.css.definition.selectors.AttributeSelector;
	import by.blooddy.code.css.definition.selectors.CSSSelector;
	import by.blooddy.code.css.definition.selectors.ChildSelector;
	import by.blooddy.code.css.definition.selectors.ClassSelector;
	import by.blooddy.code.css.definition.selectors.DescendantSelector;
	import by.blooddy.code.css.definition.selectors.IDSelector;
	import by.blooddy.code.css.definition.selectors.PseudoSelector;
	import by.blooddy.code.css.definition.selectors.TagSelector;
	import by.blooddy.code.css.definition.values.CSSValue;
	import by.blooddy.code.css.definition.values.CollectionValue;
	import by.blooddy.core.utils.ClassAlias;
	import by.blooddy.gui.display.state.IStatable;
	import by.blooddy.gui.style.meta.AbstractStyle;
	import by.blooddy.gui.style.meta.CollectionStyle;
	import by.blooddy.gui.style.meta.SimpleStyle;
	import by.blooddy.gui.style.meta.StyleInfo;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	//--------------------------------------
	//  Events
	//--------------------------------------
	
	/**
	 * @eventType			flash.events.AsyncErrorEvent.ASYNC_ERROR
	 */
	[Event( name="asyncError", type="flash.events.AsyncErrorEvent" )]
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					15.05.2010 16:46:29
	 */
	public class StyleApplyer extends EventDispatcher {
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static function filterSelector(from:Vector.<CSSRule>, to:Vector.<CSSRule>, target:DisplayObject):void {
			for each ( var rule:CSSRule in from ) {
				if ( isSelector( rule.selector, target ) ) {
					to.push( rule );
				}
			}
		}
		
		/**
		 * @private
		 */
		private static function isSelector(selector:CSSSelector, target:DisplayObject):Boolean {
			var s:AttributeSelector = selector.selector;
			var c:Class;
			do {
				switch ( true ) {
					case s is IDSelector:
						if ( ( s as IDSelector ).value != target.name ) return false;
						break;
					case s is TagSelector:
						c = ClassAlias.getClass( ( s as TagSelector ).value );
						if ( !c || !( target is c ) ) return false;
						break;
					case s is ClassSelector:
						if ( !( target is IStyleable ) ) return false;
						if ( ( target as IStyleable ).styleClass == ( s as ClassSelector ).value ) return false;
						break;
					case s is PseudoSelector:
						if ( !( target is IStatable ) || ( target as IStatable ).state != ( s as PseudoSelector ).value ) return false;
						break;
				}
			} while ( s = s.selector );
			switch ( true ) {
				case selector is DescendantSelector:
					selector = ( selector as DescendantSelector ).parent;
					while ( target = target.parent ) {
						if ( isSelector( selector, target ) ) {
							return true;
						}
					}
					return false;
				case selector is ChildSelector:
					if ( !target.parent ) return false;
					return isSelector( ( selector as DescendantSelector ).parent, target.parent );
			}
			return true;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function StyleApplyer(rules:Vector.<CSSRule>) {
			super();
			// сортируем правила
			var s:AttributeSelector;
			var tmp:Vector.<CSSRule>;
			var v:*;
			for each ( var rule:CSSRule in rules ) {
				s = rule.selector.selector;
				switch ( true ) {
					case s is TagSelector:
						v = ClassAlias.getClass( ( s as TagSelector ).value );
						if ( v ) {
							tmp = this._hash_tag[ v ];
							if ( !tmp ) this._hash_tag[ v ] = tmp = new Vector.<CSSRule>();
						} else {
							tmp = null;
						}
						break;
					case s is IDSelector:
						v = ( s as IDSelector ).value;
						tmp = this._hash_id[ v ];
						if ( !tmp ) this._hash_id[ v ] = tmp = new Vector.<CSSRule>();
						break;
					case s is ClassSelector:
						v = ( s as ClassSelector ).value;
						tmp = this._hash_class[ v ];
						if ( !tmp ) this._hash_class[ v ] = tmp = new Vector.<CSSRule>();
						break;
					case s is PseudoSelector:
						v = ( s as PseudoSelector ).value;
						tmp = this._hash_pseudo[ v ];
						if ( !tmp ) this._hash_pseudo[ v ] = tmp = new Vector.<CSSRule>();
						break;
				}
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _hash_target:Dictionary =	new Dictionary( true );

		/**
		 * @private
		 */
		private const _hash_id:Object =			new Object();

		/**
		 * @private
		 */
		private const _hash_tag:Dictionary =	new Dictionary();

		/**
		 * @private
		 */
		private const _hash_class:Object =		new Object();

		/**
		 * @private
		 */
		private const _hash_pseudo:Object =		new Object();

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function addStyleListener(target:DisplayObject):void {
			if ( target in this._hash_target ) return;
			// проверяем нашего папу
			var p:DisplayObject = target;
			while ( p = p.parent ) {
				if ( p in this._hash_target ) {
					throw new ArgumentError();
				}
			}
			// проверяем наших детей
			for ( var o:Object in this._hash_target ) {
				if (
					o is DisplayObjectContainer &&
					( o as DisplayObjectContainer ).contains( target )
				) {
					throw new ArgumentError();
				}
			}
			// всё ок
			this._hash_target[ target ] = true;
			target.addEventListener( Event.ADDED, this.handler_added, false, int.MIN_VALUE, true );
			this.apply( target );
		}

		public function removeStyleListener(target:DisplayObject):void {
			if ( !( target in this._hash_target ) ) return;
			delete this._hash_target[ target ];
			target.removeEventListener( Event.ADDED, this.handler_added );
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function apply(target:DisplayObject):void {

			var declarations:Object; // TODO: get from cache

			if ( !declarations ) {

				// собираем список правил
				var rules:Vector.<CSSRule> = new Vector.<CSSRule>();
				var tmp:Vector.<CSSRule>;
				// id
				tmp = this._hash_id[ target.name ];
				if ( tmp ) filterSelector( tmp, rules, target );
				// tag
				var n:String;
				var o:*;
				for ( o in this._hash_tag ) {
					if ( target is o ) {
						filterSelector( this._hash_tag[ o ], rules, target );
					}
				}
				// class
				if ( target is IStyleable ) {
					tmp = this._hash_class[ ( target as IStyleable ).styleClass ];
					if ( tmp ) filterSelector( tmp, rules, target );
				}
				// pseudo
				if ( target is IStatable ) {
					tmp = this._hash_pseudo[ ( target as IStatable ).state ];
					if ( tmp ) filterSelector( tmp, rules, target );
				}

				if ( rules.length > 0 ) {

					// сделаем из правил один большое declaration
					declarations = new Object();

					var info:StyleInfo = StyleInfo.getInfo( target );
					var v:CSSValue;
					var value:CSSValue;
					var values:Vector.<CSSValue>;
					var style:AbstractStyle;
					var styles:Vector.<String>;
					var i:uint, j:uint, l:uint, k:uint;
		
					for each ( var rule:CSSRule in rules ) {
						
						for ( n in rule.declarations ) {
		
							value = rule.declarations[ n ];
							style = info.getStyle( n );
							switch ( true ) {
		
								case style is SimpleStyle:
									if ( value is ( style as SimpleStyle ).type ) {
										declarations[ n ] = ( value as Object ).valueOf();
									}
									break;
		
								case style is CollectionStyle:
									styles = ( style as CollectionStyle ).styles;
									if ( value is CollectionValue ) {
		
										values = ( value as CollectionValue ).values;
										k = styles.length;
										l = values.length;
										j = 0;
										for ( i=0; i<l; i++ ) {
											v = values[ i ];
											for ( ; j<k; j++ ) {
												n = styles[ j ];
												if ( v is ( info.getStyle( n ) as SimpleStyle ).type ) {
													declarations[ n ] = ( v as Object ).valueOf();
													break;
												}
											}
										}
		
									} else {
		
										l = values.length;
										for ( j=0; j<k; j++ ) {
											n = styles[ j ];
											if ( value is ( info.getStyle( n ) as SimpleStyle ).type ) {
												declarations[ n ] = ( v as Object ).valueOf();
												break;
											}
										}
		
									}
									break;
		
							}
	
						}
	
					}

				}

				// TODO: save declarations to cache

			}

			if ( declarations ) {

				for ( n in declarations ) {
					try {
						target[ n ] = declarations[ n ];
					} catch ( e:* ) {
						super.dispatchEvent( new AsyncErrorEvent( AsyncErrorEvent.ASYNC_ERROR, false, false, e.toString(), e as Error ) );
					}
				}

			}

			// childs
			if ( target is DisplayObjectContainer ) {
				var cont:DisplayObjectContainer = target as DisplayObjectContainer;
				l = cont.numChildren;
				var child:DisplayObject;
				for ( i=0; i<l; ++i ) {
					child = cont.getChildAt( i );
					if ( child ) this.apply( child );
				}
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_added(event:Event):void {
			if ( event.target in this._hash_target ) return;
			this.apply( event.target as DisplayObject );
		}

	}

}