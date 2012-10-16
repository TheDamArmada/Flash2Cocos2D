////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.controllers.battle {

	import by.blooddy.core.commands.Command;
	import by.blooddy.core.controllers.DisplayObjectController;
	import by.blooddy.core.controllers.IBaseController;
	import by.blooddy.core.events.data.DataBaseEvent;
	import by.blooddy.core.filters.AdjustColor;
	import by.blooddy.core.utils.time.RelativeTime;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	
	import ru.avangardonline.data.battle.result.BattleResultData;
	import ru.avangardonline.data.battle.world.BattleWorldData;
	import ru.avangardonline.data.battle.world.BattleWorldEffectData;
	import ru.avangardonline.data.battle.world.BattleWorldElementCollectionData;
	import ru.avangardonline.data.battle.world.BattleWorldElementData;
	import ru.avangardonline.data.battle.world.BattleWorldFieldData;
	import ru.avangardonline.data.character.CharacterData;
	import ru.avangardonline.data.character.HeroCharacterData;
	import ru.avangardonline.display.gfx.battle.world.BattleWorldView;
	import ru.avangardonline.display.gfx.battle.world.BattleWorldViewFactory;
	import ru.avangardonline.display.gui.battle.BattleResultView;
	import ru.avangardonline.display.gui.battle.RunesView;
	import ru.avangardonline.events.data.battle.world.BattleWorldTempElementEvent;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 */
	public class BattleController extends DisplayObjectController {

		//--------------------------------------------------------------------------
		//
		//  Class viariables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static const _FILTERS:Array = new Array( AdjustColor.getFilter( 0, -1 ) );
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleController(controller:IBaseController, time:RelativeTime, container:DisplayObjectContainer) {
			super( controller, container );
			this._time = time;
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _y:Number = 0;

		/**
		 * @private
		 */
		private var _data:BattleWorldData;

		/**
		 * @private
		 */
		private var _view:BattleWorldView;

		/**
		 * @private
		 */
		private const _leftPanel:RunesView = new RunesView( true );
		
		/**
		 * @private
		 */
		private const _rightPanel:RunesView = new RunesView( false );
		
		/**
		 * @private
		 */
		private var _resultView:BattleResultView;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  time
		//----------------------------------

		/**
		 * @private
		 */
		private var _time:RelativeTime;

		public function get time():RelativeTime {
			return this._time;
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		protected override function construct():void {
			var controller:IBaseController = super.baseController;
			controller.addCommandListener( 'enterBattle',			this.enterBattle );
			controller.addCommandListener( 'exitBattle',			this.exitBattle );
			controller.addCommandListener( 'addCharacter',			this.addCharacter );
			controller.addCommandListener( 'removeCharacter',		this.removeCharacter );
			controller.addCommandListener( 'forWorldElement',		this.forWorldElement );
			controller.addCommandListener( 'createEffectAtElement',	this.createEffectAtElement );
			controller.addCommandListener( 'syncElements',			this.syncElements );
			controller.addCommandListener( 'openBattleResult',		this.openBattleResult );
			controller.addCommandListener( 'closeBattleResult',		this.closeBattleResult );
			controller.call( 'enterBattle' );
		}

		/**
		 * @private
		 */
		protected override function destruct():void {
			var controller:IBaseController = super.baseController;
			controller.removeCommandListener( 'enterBattle',			this.enterBattle );
			controller.removeCommandListener( 'exitBattle',				this.exitBattle );
			controller.removeCommandListener( 'addCharacter',			this.addCharacter );
			controller.removeCommandListener( 'removeCharacter',		this.removeCharacter );
			controller.removeCommandListener( 'forWorldElement',		this.forWorldElement );
			controller.removeCommandListener( 'createEffectAtElement',	this.createEffectAtElement );
			controller.removeCommandListener( 'syncElements',			this.syncElements );
			controller.removeCommandListener( 'openBattleResult',		this.openBattleResult );
			controller.removeCommandListener( 'closeBattleResult',		this.closeBattleResult );
			if ( this._data ) {
				this.exitBattle();
				controller.call( 'exitBattle' );
			}
		}

		/**
		 * @private
		 */
		private function update3D(event:Event=null):void {
			var x:int = - this._view.mouseX;
			var y:int = ( this._view.mouseY < 0 ? this._view.mouseY * 2 : 0 );
			var projection:PerspectiveProjection = new PerspectiveProjection();
			projection.fieldOfView = 80;
			projection.projectionCenter = new Point( x, y );
			this._view.transform.perspectiveProjection = projection;
		}

		//--------------------------------------------------------------------------
		//
		//  Command handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function enterBattle(data:BattleWorldFieldData):void {

			this._data = new BattleWorldData( this._time );
			super.dataBase.addChild( this._data );
			this._data.elements.addEventListener( DataBaseEvent.ADDED, this.handler_added );
			this._data.elements.addEventListener( DataBaseEvent.REMOVED, this.handler_removed );

			this._data.field.copyFrom( data );

			this._view = new BattleWorldView( this._data, new BattleWorldViewFactory() );

			this._view.x = 353;
			this._view.y = 320;

			var projection:PerspectiveProjection = new PerspectiveProjection();
			projection.fieldOfView = 60;
			projection.projectionCenter = new Point( 0, -580 );
			this._view.transform.perspectiveProjection = projection;

			super.container.addChild( this._view );
			super.container.addChild( this._leftPanel );
			super.container.addChild( this._rightPanel );
			
			this._leftPanel.x = 24;
			this._leftPanel.y = 24;
			
			this._rightPanel.x = 682;
			this._rightPanel.y = 24;
			
			//super.container.addEventListener( MouseEvent.MOUSE_MOVE, this.update3D );

		}

		/**
		 * @private
		 */
		private function exitBattle():void {
			//super.container.removeEventListener( MouseEvent.MOUSE_MOVE, this.update3D );
			if ( this._resultView ) this.closeBattleResult();
			super.container.removeChild( this._rightPanel );
			super.container.removeChild( this._leftPanel );
			super.container.removeChild( this._view );
			this._view = null;
			this._data.elements.removeEventListener( DataBaseEvent.ADDED, this.handler_added );
			this._data.elements.removeEventListener( DataBaseEvent.REMOVED, this.handler_removed );
			super.dataBase.removeChild( this._data );
			this._data = null;
		}

		/**
		 * @private
		 */
		private function syncElements(collection:BattleWorldElementCollectionData):void {
			this._data.elements.copyFrom( collection );
		}

		/**
		 * @private
		 */
		private function addCharacter(data:CharacterData):void {
			var character:CharacterData = this._data.elements.getElement( data.id ) as CharacterData;
			if ( character ) {
				trace( 'ASYNC: addCharacter' );
				character.copyFrom( data );
			} else {
				this._data.elements.addChild( data.clone() );
			}
		}

		/**
		 * @private
		 */
		private function removeCharacter(id:uint):void {
			var character:CharacterData = this._data.elements.getElement( id ) as CharacterData;
			if ( !character ) throw new ArgumentError();
			this._data.elements.removeChild( character );
		}

		/**
		 * @private
		 */
		private function forWorldElement(id:uint, command:Command):void {
			command.call( this._data.elements.getElement( id ) );
		}

		/**
		 * @private
		 */
		private function createEffectAtElement(effectType:uint, id:uint):void {
			var el:BattleWorldElementData = this._data.elements.getElement( id );
			var ef:BattleWorldEffectData = new BattleWorldEffectData( effectType );
			ef.coord.copyFrom( el.coord );
			this._data.dispatchEvent( new BattleWorldTempElementEvent( BattleWorldTempElementEvent.ADD_ELEMENT, false, false, ef ) );
		}

		/**
		 * @private
		 */
		private function openBattleResult(data:BattleResultData):void {
			var params:Object = super.container.loaderInfo.parameters;
			var heroName:String = params.characterName;
			var type:uint = parseInt( params.type );
			var hero:HeroCharacterData = this._data.elements.getChildByName( heroName ) as HeroCharacterData;
			this._view.filters = _FILTERS;
			this._resultView = new BattleResultView( data, hero, type );
			this._resultView.addEventListener( 'replay',	this.handler_replay );
			this._resultView.addEventListener( 'continue',	this.handler_continue );
			super.container.addChild( this._resultView );
		}

		/**
		 * @private
		 */
		private function closeBattleResult():void {
			this._view.filters = null;
			if ( this._resultView ) {
				super.container.removeChild( this._resultView );
				this._resultView.removeEventListener( 'replay',		this.handler_replay );
				this._resultView.removeEventListener( 'continue',	this.handler_continue );
				//this._resultView.dispose();
				this._resultView = null;
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
		private function handler_replay(event:Event):void {
			super.baseController.call( 'resetBattle' );
		}

		/**
		 * @private
		 */
		private function handler_continue(event:Event):void {
			super.baseController.call( 'closeBattle' );
		}

		/**
		 * @private
		 */
		private function handler_added(event:DataBaseEvent):void {
			var data:HeroCharacterData = event.target as HeroCharacterData;
			if ( data ) {
				switch ( data.group ) {
					case 1:		this._leftPanel.data = data as HeroCharacterData;	break;
					case 2:		this._rightPanel.data = data as HeroCharacterData;	break;
				}
			}
		}
		
		/**
		 * @private
		 */
		private function handler_removed(event:DataBaseEvent):void {
			var data:HeroCharacterData = event.target as HeroCharacterData;
			if ( data ) {
				switch ( data.group ) {
					case 1:		this._leftPanel.data = null;	break;
					case 2:		this._rightPanel.data = null;	break;
				}
			}
		}
		
	}

}