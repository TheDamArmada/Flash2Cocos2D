////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.gui.style {

	import by.blooddy.code.css.definition.values.ArrayValue;
	import by.blooddy.code.css.definition.values.BooleanValue;
	import by.blooddy.code.css.definition.values.ColorValue;
	import by.blooddy.code.css.definition.values.IdentifierValue;
	import by.blooddy.code.css.definition.values.NumberValue;
	import by.blooddy.code.css.definition.values.PercentValue;
	import by.blooddy.code.css.definition.values.StringValue;
	import by.blooddy.code.css.definition.values.URLValue;
	import by.blooddy.core.utils.ClassUtils;
	import by.blooddy.gui.parser.css.values.BitmapFilterValue;
	import by.blooddy.gui.parser.css.values.MatrixValue;
	import by.blooddy.gui.parser.css.values.PointValue;
	import by.blooddy.gui.parser.css.values.RectValue;
	
	import flash.filters.BitmapFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					26.08.2010 14:46:43
	 */
	public final class StyleType {
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		private static const _PROTO_ARRAY:Object =		Array.prototype;
		
		private static const _PROTO_BOOLEAN:Object =	Boolean.prototype;
		
		private static const _PROTO_NUMBER:Object =		Number.prototype;

		private static const _PROTO_STRING:Object =		String.prototype;
		
		private static const _PROTO_FILTER:Object =		BitmapFilter.prototype;
		
		private static const _PROTO_MATRIX:Object =		Matrix.prototype;
		
		private static const _PROTO_POINT:Object =		Point.prototype;
		
		private static const _PROTO_RECT:Object =		Rectangle.prototype;
		
		private static const _NAME_ARRAY:QName =		ClassUtils.getClassQName( Array );
		
		private static const _NAME_BOOLEAN:QName =		ClassUtils.getClassQName( Boolean );
		
		private static const _NAME_NUMBER:QName =		ClassUtils.getClassQName( Number );
		
		private static const _NAME_STRING:QName =		ClassUtils.getClassQName( String );
		
		private static const _NAME_FILTER:QName =		ClassUtils.getClassQName( BitmapFilter );
		
		private static const _NAME_MATRIX:QName =		ClassUtils.getClassQName( Matrix );
		
		private static const _NAME_POINT:QName =		ClassUtils.getClassQName( Point );
		
		private static const _NAME_RECT:QName =			ClassUtils.getClassQName( Rectangle );
		
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		public static const ARRAY:String =		'array';

		public static const BOOLEAN:String =	'boolean';

		public static const COLOR:String =		'color';

		public static const IDENTIFIER:String =	'identifier';

		public static const NUMBER:String =		'number';
		
		public static const PERCENT:String =	'percent';
		
		public static const STRING:String =		'string';
		
		public static const URL:String =		'url';

		public static const FILTER:String =		'filter';
		
		public static const MATRIX:String =		'matrix';
		
		public static const POINT:String =		'point';
		
		public static const RECT:String =		'rect';
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function getValueByType(type:String):Class {
			switch ( type.toLowerCase() ) {
				case NUMBER:		return NumberValue;
				case PERCENT:		return PercentValue;
				case BOOLEAN:		return BooleanValue;
				case COLOR:			return ColorValue;
				case STRING:		return StringValue;
				case URL:			return URLValue;
				case RECT:			return RectValue;
				case POINT:			return PointValue;
				case IDENTIFIER:	return IdentifierValue;
				case FILTER:		return BitmapFilterValue;
				case ARRAY:			return ArrayValue;
				case MATRIX:		return MatrixValue;
			}
			return null;
		}

		public static function getClassByQName(type:QName):Class {
			if		( type ==_NAME_NUMBER )		return NumberValue;
			else if	( type ==_NAME_BOOLEAN )	return BooleanValue;
			else if	( type ==_NAME_STRING )		return StringValue;
			else if	( type ==_NAME_RECT )		return RectValue;
			else if	( type ==_NAME_POINT )		return PointValue;
			else if	( type ==_NAME_FILTER )		return BitmapFilterValue;
			else if	( type ==_NAME_ARRAY )		return ArrayValue;
			else if	( type ==_NAME_MATRIX )		return MatrixValue;
			return null;
		}
		
		public static function getValueByClass(cls:Class):Class {
			if ( cls ) {
				var p:Object = cls.prototype;
				switch ( true ) {
					case _PROTO_NUMBER === p:
					case _PROTO_NUMBER.isPrototypeOf( p ):	return NumberValue;
					case _PROTO_BOOLEAN === p:
					case _PROTO_BOOLEAN.isPrototypeOf( p ):	return BooleanValue;
					case _PROTO_STRING === p:
					case _PROTO_STRING.isPrototypeOf( p ):	return StringValue;
					case _PROTO_RECT === p:
					case _PROTO_RECT.isPrototypeOf( p ):	return RectValue;
					case _PROTO_POINT === p:
					case _PROTO_POINT.isPrototypeOf( p ):	return PointValue;
					case _PROTO_FILTER === p:
					case _PROTO_FILTER.isPrototypeOf( p ):	return BitmapFilterValue;
					case _PROTO_ARRAY === p:
					case _PROTO_ARRAY.isPrototypeOf( p ):	return ArrayValue;
					case _PROTO_MATRIX === p:
					case _PROTO_MATRIX.isPrototypeOf( p ):	return MatrixValue;
				}
			}
			return null;
		}

	}

}