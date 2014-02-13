package com.nudoru.utils {
   
   import flash.filters.ColorMatrixFilter;
   
   /**
   * Holds saturation data which can then be applied to a Sprite or MovieClip as a ColorMatrixFilter
   *
   * e.g.
   * var mySaturationData = new SaturationData();
   * mySaturationData.desaturate();
   * mySprite.filters = [mySaturationData.getSaturation()];
   *
   * @author Devon O., http://www.onebyonedesign.com/
   *
   */
   public class SaturationData {
      
      private const IDENTITY:Array = [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0];
      
      private var _colorFilter:ColorMatrixFilter = new ColorMatrixFilter(IDENTITY);
      private var _s:Number = 1;
      
      //   Empty constructor
      public function SaturationData():void { };
      
      public function getSaturation():ColorMatrixFilter { return _colorFilter; }
      
      /**
       *
       * @param   s   Number ranging from 0 to 2 (0 = Desaturated, 1 = Identity, 2 = Saturated)
       * @throws   RangeError
       */
      public function set saturation(s:Number):void {
         if (s >= 0 && s <= 2 ) {
            _s = s;
            _colorFilter.matrix = [0.114 + 0.886 * _s, 0.299 * (1 - _s), 0.587 * (1 - _s), 0, 0, 0.114 * (1 - _s), 0.299 + 0.701 * _s, 0.587 * (1 - _s), 0, 0, 0.114 * (1 - _s), 0.299 * (1 - _s), 0.587 + 0.413 * _s, 0, 0, 0, 0, 0, 1, 0];
         } else {
            throw new RangeError("SaturationData.setSaturation() method must have Number argument ranging from 0 to 2.");
         }
      }
      
      public function desaturate():void {
         saturation = 0;
      }
      
      public function saturate():void {
         saturation = 2;
      }
      
      public function reset():void {
         saturation = 1;
      }
   }
}