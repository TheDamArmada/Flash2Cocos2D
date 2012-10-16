////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils {

	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;

	/**
	 * Утилиты для работы с классами.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					сlassutils, class, utils
	 */
	public final class ClassUtils {

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function parseClassQName(name:String):QName {
			var i:int = name.lastIndexOf( '::' );
			if ( i < 0 ) {
				return new QName( '', name );
			} else {
				return new QName( name.substr( 0, i ), name.substr( i + 2 ) );
			}
		}

		public static function parseClassName(name:String):String {
			var i:int = name.lastIndexOf( '::' );
			if ( i > 0 ) name = name.substr( i + 2 );
			return name;
		}

		public static function getClassQName(o:Object):QName {
			return parseClassQName( getQualifiedClassName( o ) );
		}

		/**
		 * @param	value			Объект, имя класса, которого нужно узнать.
		 *
		 * @return					Имя класса.
		 *
		 * @keyword 				classutils.getclassname, getclassname, classname, class
		 *
		 * @see						flash.utils.getQualifiedClassName()
		 */
		public static function getClassName(o:Object):String {
			return parseClassName( getQualifiedClassName( o ) );
		}

		/**
		 * @param	value			Объект, имя класса, которого нужно узнать.
		 *
		 * @return					Имя класса.
		 *
		 * @keyword 				classutils.getsuperclassname, getsuperclassname, supercclassname, classname, class
		 *
		 * @see						flash.utils.getQualifiedSuperclassName()
		 */
		public static function getSuperclassName(o:Object):String {
			return parseClassName( getQualifiedSuperclassName( o ) );
		}

		public static function getClass(o:Object):Class {
			if ( o is Class ) {
				return o as Class;
			} else {
				var c:Class = o.constructor as Class;
				if ( c && o is c ) {
					return c;
				} else {
					return getClassFromName( o );
				}
			}
		}

		public static function getClassFromName(o:Object):Class {
			return ClassAlias.getClass( getQualifiedClassName( o ) );
		}

		public static function getSuperclassFromName(o:Object):Class {
			var name:String = getQualifiedSuperclassName( o );
			if ( name ) {
				return ClassAlias.getClass( name );
			}
			return null;
		}

	}

}