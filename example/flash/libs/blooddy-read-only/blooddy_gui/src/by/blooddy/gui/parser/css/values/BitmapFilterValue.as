////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.gui.parser.css.values {
	
	import by.blooddy.code.css.definition.values.ArrayValue;
	import by.blooddy.code.css.definition.values.CSSValue;
	import by.blooddy.code.css.definition.values.ColorValue;
	
	import flash.filters.BevelFilter;
	import flash.filters.BitmapFilter;
	import flash.filters.BlurFilter;
	import flash.filters.ConvolutionFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.filters.GradientBevelFilter;
	import flash.filters.GradientGlowFilter;
	import flash.filters.ColorMatrixFilter;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					09.05.2010 17:07:16
	 */
	public class BitmapFilterValue extends CSSValue {
		
		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static function toArray(filter:BitmapFilter):Array {
			var arr:Array;
			var c:uint;
			switch ( true ) {
				case filter is BevelFilter:			// number,number,color,number,color,number,number,number,number,number,string,boolean
					var f1:BevelFilter = filter as BevelFilter;
					return new Array(
						'bevel',
						f1.distance,
						f1.angle,
						new ColorValue( f1.highlightColor ),
						f1.highlightAlpha,
						new ColorValue( f1.shadowColor ),
						f1.shadowAlpha,
						f1.blurX,
						f1.blurY,
						f1.strength,
						f1.quality,
						f1.type,
						f1.knockout
					);
				case filter is BlurFilter:			// number,number,number
					var f2:BlurFilter = filter as BlurFilter;
					return new Array(
						'blur',
						f2.blurX,
						f2.blurY,
						f2.quality
					);
				case filter is ConvolutionFilter:	// number,number,array[number],number,number,boolean,boolean,color,number
					var f3:ConvolutionFilter = filter as ConvolutionFilter;
					return new Array(
						'convolution',
						f3.matrixX,
						f3.matrixY,
						new ArrayValue( f3.matrix ),
						f3.divisor,
						f3.bias,
						f3.preserveAlpha,
						f3.clamp,
						new ColorValue( f3.color ),
						f3.alpha
					);
				case filter is DropShadowFilter:	// number,number,color,number,number,number,number,number,boolean,boolean,boolean
					var f4:DropShadowFilter = filter as DropShadowFilter;
					return new Array(
						'dropShadow',
						f4.distance,
						f4.angle,
						new ColorValue( f4.color ),
						f4.alpha,
						f4.blurX,
						f4.blurY,
						f4.strength,
						f4.quality,
						f4.inner,
						f4.knockout,
						f4.hideObject
					);
				case filter is GlowFilter:			// color,number,number,number,number,number,boolean,boolean
					var f5:GlowFilter = filter as GlowFilter;
					return new Array(
						'glow',
						new ColorValue( f5.color ),
						f5.alpha,
						f5.blurX,
						f5.blurY,
						f5.strength,
						f5.quality,
						f5.inner,
						f5.knockout
					);
				case filter is GradientBevelFilter:	// number,number,array[color],array[number],array[number],number,number,number,number,string,boolean
					var f6:GradientBevelFilter = filter as GradientBevelFilter;
					arr = new Array();
					for each ( c in f6.colors ) {
						arr.push( new ColorValue( c ) );
					}
					return new Array(
						'gradientBevel',
						f6.distance,
						f6.angle,
						new ArrayValue( arr ),
						new ArrayValue( f6.alphas ),
						new ArrayValue( f6.ratios ),
						f6.blurX,
						f6.blurY,
						f6.strength,
						f6.quality,
						f6.type,
						f6.knockout
					);
				case filter is GradientGlowFilter:	// number,number,array[color],array[number],array[number],number,number,number,number,string,boolean
					var f7:GradientGlowFilter = filter as GradientGlowFilter;
					arr = new Array();
					for each ( c in f7.colors ) {
						arr.push( new ColorValue( c ) );
					}
					return new Array(
						'gradientGlow',
						f7.distance,
						f7.angle,
						new ArrayValue( arr ),
						new ArrayValue( f7.alphas ),
						new ArrayValue( f7.ratios ),
						f7.blurX,
						f7.blurY,
						f7.strength,
						f7.quality,
						f7.type,
						f7.knockout
					);
				case filter is ColorMatrixFilter:
					return new Array(
						'colorMatrix',
						new ArrayValue( ( filter as ColorMatrixFilter ).matrix )
					);
			}
			throw new ArgumentError();
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function BitmapFilterValue(value:BitmapFilter) {
			super();
			this.value = value;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		public var value:BitmapFilter;
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		public function valueOf():BitmapFilter {
			return this.value;
		}
		
		public function toString():String {
			return 'filter(' + toArray( this.value ) + ')';
		}
		
	}
	
}