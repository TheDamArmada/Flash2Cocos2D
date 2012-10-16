////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.filters {

	import flash.filters.BitmapFilter;
	import by.blooddy.core.utils.ClassUtils;

	/**
	 * Класс GlowAnimationFilter.
	 * 
	 * @author					BloodHound, andreus
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */

	public function compareFilters(f1:BitmapFilter, f2:BitmapFilter):Boolean {
		if ( f1 === f2 ) return true;
		var c1:Class = ( f1 as Object ).constructor as Class;
		if ( c1 !== ( f2 as Object ).constructor ) return false;
		if ( c1 in _HASH ) {
			return _HASH[ c1 ](f1, f2);
		}
		return false;
	}

}

import flash.utils.Dictionary;
import flash.filters.GlowFilter;
import flash.filters.BlurFilter;
import flash.filters.ColorMatrixFilter;
import flash.filters.BevelFilter;
import flash.filters.ConvolutionFilter;
import flash.filters.DisplacementMapFilter;
import flash.filters.DropShadowFilter;
import flash.filters.GradientBevelFilter;
import flash.filters.GradientGlowFilter;

internal const _HASH:Dictionary = new Dictionary();

_HASH[ GlowFilter ] = compare_GlowFilters;
_HASH[ BlurFilter ] = compare_BlurFilters;
_HASH[ ColorMatrixFilter ] = compare_ColorMatrixFilter;
_HASH[ BevelFilter ] = compare_BevelFilter;
_HASH[ ConvolutionFilter ] = compare_ConvolutionFilter;
_HASH[ DisplacementMapFilter ] = compare_DisplacementMapFilter;
_HASH[ DropShadowFilter ] = compare_DropShadowFilter;
_HASH[ GradientBevelFilter ] = compare_GradientBevelFilter;
_HASH[ GradientGlowFilter ] = compare_GradientGlowFilter;

internal function compare_GlowFilters(f1:GlowFilter, f2:GlowFilter):Boolean {
	return (
		f1.color == f2.color &&
		f1.alpha == f2.alpha &&
		f1.blurX == f2.blurX &&
		f1.blurY == f2.blurY &&
		f1.strength == f2.strength &&
		f1.inner == f2.inner &&
		f1.knockout == f1.knockout &&
		f1.quality == f2.quality
	);
}

internal function compare_BlurFilters(f1:BlurFilter, f2:BlurFilter):Boolean {
	return (
		f1.blurX == f2.blurX &&
		f1.blurY == f2.blurY &&
		f1.quality == f2.quality
	);
}

internal function compare_ColorMatrixFilter(f1:ColorMatrixFilter, f2:ColorMatrixFilter):Boolean {
	return (
		compare_Array(f1.matrix , f2.matrix)
	);
}

internal function compare_BevelFilter(f1:BevelFilter, f2:BevelFilter):Boolean {
	return (
		f1.distance == f2.distance &&
		f1.angle == f2.angle &&
		f1.highlightColor == f2.highlightColor && 
		f1.highlightAlpha == f2.highlightAlpha &&
		f1.shadowColor == f2.shadowColor &&
		f1.shadowAlpha == f2.shadowAlpha &&
		f1.blurX == f2.blurX &&
		f1.blurY == f2.blurY &&
		f1.strength == f2.strength && 
		f1.quality == f2.quality &&
		f1.type == f2.type &&
		f1.knockout == f2.knockout
	);
}
internal function compare_ConvolutionFilter(f1:ConvolutionFilter, f2:ConvolutionFilter):Boolean {
	return (
		f1.matrixX == f2.matrixX &&
		f1.matrixY == f2.matrixY && 
		f1.divisor == f2.divisor &&
		f1.bias == f2.bias && 
		f1.preserveAlpha == f2.preserveAlpha && 
		f1.clamp == f2.clamp && 
		f1.color == f2.color && 
		f1.alpha == f2.alpha &&
		compare_Array(f1.matrix, f2.matrix)
	);
}
internal function compare_DisplacementMapFilter(f1:DisplacementMapFilter, f2:DisplacementMapFilter):Boolean {
	return (
		f1.mapBitmap === f2.mapBitmap && 
		f1.mapPoint === f2.mapPoint && 
		f1.componentX == f2.componentX && 
		f1.componentY == f2.componentY && 
		f1.scaleX == f2.scaleX && 
		f1.scaleY == f2.scaleY && 
		f1.mode == f2.mode && 
		f1.color == f2.color && 
		f1.alpha == f2.alpha
	);
}
internal function compare_DropShadowFilter(f1:DropShadowFilter, f2:DropShadowFilter):Boolean {
	return (
		f1.distance == f2.distance &&
		f1.angle == f2.angle &&
		f1.color == f2.color && 
		f1.alpha == f2.alpha && 
		f1.blurX == f2.blurX && 
		f1.blurY == f2.blurY && 
		f1.strength == f2.strength &&
		f1.quality == f2.quality && 
		f1.inner == f2.inner && 
		f1.knockout == f2.knockout && 
		f1.hideObject == f2.hideObject
	);
}
internal function compare_GradientBevelFilter(f1:GradientBevelFilter, f2:GradientBevelFilter):Boolean {
	return (
		f1.distance == f2.distance && 
		f1.angle == f2.angle && 
		f1.blurX == f2.blurX && 
		f1.blurY == f2.blurY && 
		f1.strength == f2.strength && 
		f1.quality == f2.quality && 
		f1.type == f2.type && 
		f1.knockout == f2.knockout &&
		compare_Array(f1.colors, f1.colors) && 
		compare_Array(f1.alphas, f1.alphas) &&
		compare_Array(f1.ratios, f1.ratios)
	);
}
internal function compare_GradientGlowFilter(f1:GradientGlowFilter, f2:GradientGlowFilter):Boolean {
	return (
		f1.distance == f2.distance && 
		f1.angle == f2.angle && 
		f1.blurX == f2.blurX && 
		f1.blurY == f2.blurY && 
		f1.strength == f2.strength && 
		f1.quality == f2.quality && 
		f1.type == f2.type && 
		f1.knockout == f2.knockout &&
		compare_Array(f1.colors, f1.colors) &&
		compare_Array(f1.alphas, f1.alphas) &&
		compare_Array(f1.ratios, f1.ratios)
	);
}

internal function compare_Array(a1:Array, a2:Array):Boolean {
	var l1:int = a1.length;
	if ( l1 != a2.length ) return false;
	for ( var i:int = 0; i<l1; ++i ) {
		if ( a1[i] != a2[i] ) return false;
	}
	return true;
}
