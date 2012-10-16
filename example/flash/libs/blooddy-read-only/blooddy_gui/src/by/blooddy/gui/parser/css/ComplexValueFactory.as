////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.gui.parser.css {

	import by.blooddy.code.css.definition.values.ArrayValue;
	import by.blooddy.code.css.definition.values.BooleanValue;
	import by.blooddy.code.css.definition.values.CSSValue;
	import by.blooddy.code.css.definition.values.ColorValue;
	import by.blooddy.code.css.definition.values.ComplexValue;
	import by.blooddy.code.css.definition.values.NumberValue;
	import by.blooddy.code.css.definition.values.StringValue;
	import by.blooddy.core.filters.AdjustColor;
	import by.blooddy.gui.parser.css.values.BitmapFilterValue;
	import by.blooddy.gui.parser.css.values.MatrixValue;
	import by.blooddy.gui.parser.css.values.PointValue;
	import by.blooddy.gui.parser.css.values.RectValue;
	
	import flash.filters.BevelFilter;
	import flash.filters.BitmapFilter;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.ConvolutionFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.filters.GradientBevelFilter;
	import flash.filters.GradientGlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					09.05.2010 19:29:33
	 */
	public final class ComplexValueFactory {
		
		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static function getObject(name:String):Object {
			switch ( name ) {
				case 'adjustColor':		return new Array( 0, 0, 0, 0, 0 );
				case 'bevel':			return new BevelFilter();
				case 'blur':			return new BlurFilter();
				case 'convolution':		return new ConvolutionFilter();
				case 'dropShadow':		return new DropShadowFilter();
				case 'glow':			return new GlowFilter();
				case 'gradientBevel':	return new GradientBevelFilter();
				case 'gradientGlow':	return new GradientGlowFilter();
				case 'colorMatrix':		return new ColorMatrixFilter();
			}
			return null;
		}

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		public static function getValue(value:ComplexValue):CSSValue {
			var vv:Vector.<CSSValue> = value.values;
			switch ( value.name ) {
				case 'filter':
					if ( vv[ 0 ] is StringValue ) {
						var n:String = ( vv[ 0 ] as StringValue ).value;
						var h:Vector.<ValueAsset> = Filters[ n ];
						if ( h ) {
							var f:Object = getObject( n );
							var s:ValueAsset;
							var l1:uint = vv.length;
							var l2:uint = h.length;
							var i1:uint, i2:uint;
							var k:uint = 0;
							var v:CSSValue;
							for ( i1 = 1; i1<l1 && k<l2; ++i1 ) {
								v = vv[ i1 ];
								for ( i2=k; i2<l2; ++i2 ) {
									s = h[ i2 ];
									if ( v is s.type ) {
										f[ s.name ] = v;
										k = i2 + 1;
										break;
									}
								}
							}
							if ( n == 'adjustColor' ) f = AdjustColor.getFilter.apply( null, f as Array );
							if ( f ) return new BitmapFilterValue( f as BitmapFilter );
						}
					}
					break;
				case 'rect':
					var r:Rectangle = new Rectangle();
					if ( vv.length > 0 && vv[ 0 ] is NumberValue ) {
						r.x = ( vv[ 0 ] as NumberValue ).value;
						if ( vv.length > 1 && vv[ 1 ] is NumberValue ) {
							r.y = ( vv[ 1 ] as NumberValue ).value;
							if ( vv.length > 2 && vv[ 2 ] is NumberValue ) {
								r.width = ( vv[ 2 ] as NumberValue ).value;
								if ( vv.length > 3 && vv[ 3 ] is NumberValue ) {
									r.height = ( vv[ 3 ] as NumberValue ).value;
								}
							}
						}
					}
					return new RectValue( r );
				case 'point':
					var p:Point = new Point();
					if ( vv.length > 0 && vv[ 0 ] is NumberValue ) {
						r.x = ( vv[ 0 ] as NumberValue ).value;
						if ( vv.length > 1 && vv[ 1 ] is NumberValue ) {
							r.y = ( vv[ 1 ] as NumberValue ).value;
						}
					}
					return new PointValue( p );
				case 'matrix':
					var m:Matrix = new Matrix();
					if ( vv.length > 0 && vv[ 0 ] is NumberValue ) {
						m.a = ( vv[ 0 ] as NumberValue ).value;
						if ( vv.length > 1 && vv[ 1 ] is NumberValue ) {
							m.b = ( vv[ 1 ] as NumberValue ).value;
							if ( vv.length > 2 && vv[ 2 ] is NumberValue ) {
								m.c = ( vv[ 2 ] as NumberValue ).value;
								if ( vv.length > 3 && vv[ 3 ] is NumberValue ) {
									m.d = ( vv[ 3 ] as NumberValue ).value;
									if ( vv.length > 4 && vv[ 4 ] is NumberValue ) {
										m.tx = ( vv[ 4 ] as NumberValue ).value;
										if ( vv.length > 5 && vv[ 5 ] is NumberValue ) {
											m.ty = ( vv[ 5 ] as NumberValue ).value;
										}
									}
								}
							}
						}
					}
					return new MatrixValue( m );
			}
			return value;
		}
		
	}
	
}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import by.blooddy.code.css.definition.values.ArrayValue;
import by.blooddy.code.css.definition.values.BooleanValue;
import by.blooddy.code.css.definition.values.ColorValue;
import by.blooddy.code.css.definition.values.NumberValue;
import by.blooddy.code.css.definition.values.StringValue;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: ValueAsset
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 */
internal final class ValueAsset {

	public function ValueAsset(type:Class, name:String) {
		super();
		this.type = type;
		this.name = name;
	}

	public var type:Class;

	public var name:String;

}

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: Filters
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 * данные по фильтрам
 */
internal final class Filters {

	public static const blur:Vector.<ValueAsset> = new <ValueAsset>[
		new ValueAsset( NumberValue,	'blurX' ),
		new ValueAsset( NumberValue,	'blurY' ),
		new ValueAsset( NumberValue,	'quality' )
	];
	
	public static const glow:Vector.<ValueAsset> = new <ValueAsset>[
		new ValueAsset( ColorValue,		'color' ),
		new ValueAsset( NumberValue,	'alpha' ),
		blur[ 0 ],						// blurX
		blur[ 1 ],						// blurY
		new ValueAsset( NumberValue,	'strength' ),
		blur[ 2 ],						// quality
		new ValueAsset( BooleanValue,	'inner' ),
		new ValueAsset( BooleanValue,	'knockout' )
	];
	
	public static const dropShadow:Vector.<ValueAsset> = new <ValueAsset>[
		new ValueAsset( NumberValue,	'distance'		),
		new ValueAsset( NumberValue,	'angle'			),
		glow[ 0 ],						// color
		glow[ 1 ],						// alpha
		glow[ 2 ],						// blurX
		glow[ 3 ],						// blurY
		glow[ 4 ],						// strength
		glow[ 5 ],						// quality
		glow[ 6 ],						// inner
		glow[ 7 ],						// knockout
		new ValueAsset( BooleanValue,	'hideObject'	)
	];

	public static const bevel:Vector.<ValueAsset> = new <ValueAsset>[
		dropShadow[ 0 ],				// distance
		dropShadow[ 1 ],				// angle
		new ValueAsset( ColorValue,		'highlightColor' ),
		new ValueAsset( NumberValue,	'highlightAlpha' ),
		new ValueAsset( ColorValue,		'shadowColor' ),
		new ValueAsset( NumberValue,	'shadowAlpha' ),
		dropShadow[ 4 ],				// blurX
		dropShadow[ 5 ],				// blurY
		dropShadow[ 6 ],				// strength
		dropShadow[ 7 ],				// quality
		new ValueAsset( StringValue,	'type' ),
		dropShadow[ 9 ]					// knockout
	];
	
	public static const convolution:Vector.<ValueAsset> = new <ValueAsset>[
		new ValueAsset( NumberValue,	'matrixX' ),
		new ValueAsset( NumberValue,	'matrixY' ),
		new ValueAsset( ArrayValue,		'matrix' ),
		new ValueAsset( NumberValue,	'divisor' ),
		new ValueAsset( NumberValue,	'bias' ),
		new ValueAsset( BooleanValue,	'preserveAlpha' ),
		new ValueAsset( BooleanValue,	'clamp' ),
		dropShadow[ 2 ],				// color
		dropShadow[ 3 ]					// alpha
	];
	
	public static const gradientGlow:Vector.<ValueAsset> = new <ValueAsset>[
		bevel[ 0 ],						// distance
		bevel[ 1 ],						// angle
		new ValueAsset( ArrayValue,		'colors' ),
		new ValueAsset( ArrayValue,		'alphas' ),
		new ValueAsset( ArrayValue,		'ratios' ),
		bevel[ 6 ],						// blurX
		bevel[ 7 ],						// blurY
		bevel[ 8 ],						// strength
		bevel[ 9 ],						// quality
		bevel[ 10 ],					// type
		bevel[ 11 ]						// knockout
	];
	
	public static const gradientBevel:Vector.<ValueAsset> = gradientGlow;
	
	public static const adjustColor:Vector.<ValueAsset> = new <ValueAsset>[
		new ValueAsset( NumberValue,	'0' ),
		new ValueAsset( NumberValue,	'1' ),
		new ValueAsset( NumberValue,	'2' ),
		new ValueAsset( NumberValue,	'3' ),
		new ValueAsset( ColorValue,		'4' )
	];

	public static const colorMatrix:Vector.<ValueAsset> = new <ValueAsset>[
		new ValueAsset( ArrayValue,		'matrix' )
	];
	
}