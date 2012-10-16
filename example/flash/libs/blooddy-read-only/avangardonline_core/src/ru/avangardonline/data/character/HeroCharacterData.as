////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.data.character {

	import by.blooddy.core.data.Data;
	
	import flash.errors.IllegalOperationError;
	
	import ru.avangardonline.data.items.RuneData;
	import ru.avangardonline.events.data.character.HeroCharacterDataEvent;

	//--------------------------------------
	//  Events
	//--------------------------------------
	
	[Event( name="cast", type="ru.avangardonline.events.data.character.HeroCharacterDataEvent" )]
	[Event( name="victory", type="ru.avangardonline.events.data.character.HeroCharacterDataEvent" )]
	[Event( name="lose", type="ru.avangardonline.events.data.character.HeroCharacterDataEvent" )]
	[Event( name="normalize", type="ru.avangardonline.events.data.character.HeroCharacterDataEvent" )]
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					19.08.2009 22:11:37
	 */
	public class HeroCharacterData extends CharacterData {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function HeroCharacterData(id:uint, name:String) {
			super( id );
			super.name = name;
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _runes:Vector.<RuneData> = new Vector.<RuneData>();

		//--------------------------------------------------------------------------
		//
		//  Proeprties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  name
		//----------------------------------

		/**
		 * @private
		 */
		public override function set name(value:String):void {
			throw new IllegalOperationError();
		}

		//----------------------------------
		//  sex
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _sex:Boolean;
		
		public function get sex():Boolean {
			return this._sex;
		}
		
		/**
		 * @private
		 */
		public function set sex(value:Boolean):void {
			if ( this._sex == value ) return;
			this._sex = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function getRunes():Vector.<RuneData> {
			return this._runes.slice();
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		public override function toLocaleString():String {
			return super.formatToString( 'id', 'name', 'group', 'sex' );
		}

		public override function clone():Data {
			var result:HeroCharacterData = new HeroCharacterData( super.id, super.name );
			result.copyFrom( this );
			return result;
		}

		public override function copyFrom(data:Data):void {
			var target:HeroCharacterData = data as HeroCharacterData;
			if ( !target ) throw new ArgumentError();
			super.copyFrom( target );
			this.sex = target._sex;
			var rune:RuneData;
			for each ( rune in this._runes ) {
				super.removeChild( rune );
			}
			for each ( rune in target._runes ) {
				super.addChild( rune.clone() );
			}
		}

		public function cast(effectType:uint):void {
			super.dispatchEvent( new HeroCharacterDataEvent( HeroCharacterDataEvent.CAST ) );
		}
		
		public function victory():void {
			super.dispatchEvent( new HeroCharacterDataEvent( HeroCharacterDataEvent.VICTORY ) );
		}
		
		public function lose():void {
			super.dispatchEvent( new HeroCharacterDataEvent( HeroCharacterDataEvent.LOSE ) );
		}

		public function normalize():void {
			super.dispatchEvent( new HeroCharacterDataEvent( HeroCharacterDataEvent.NORMALIZE ) );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		protected override function addChild_before(child:Data):void {
			super.addChild_before( child );
			if ( child is RuneData ) {
				this._runes.push( child as RuneData );
			}
		}

		protected override function removeChild_before(child:Data):void {
			super.addChild_before( child );
			if ( child is RuneData ) {
				var i:int = this._runes.indexOf( child as RuneData );
				this._runes.splice( i, 1 );
			}
		}
		
	}

}