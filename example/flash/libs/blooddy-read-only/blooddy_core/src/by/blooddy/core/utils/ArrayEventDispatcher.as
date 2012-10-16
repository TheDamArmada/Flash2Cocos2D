////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils {

	import flash.utils.flash_proxy;
	import flash.events.Event;
	import by.blooddy.core.utils.proxy.ProxyEventDispatcher;

	use namespace flash_proxy;

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * Транслируется, когда происходит изменение массива.
	 * 
	 * @eventType				flash.events.Event#CHANGE
	 */
	[Event( name="change", type="flash.events.Event" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					arrayeventdispatcher, array, eventdispatcher
	 */
	public dynamic class ArrayEventDispatcher extends ProxyEventDispatcher {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @copy		Array#Array
		 */
		public function ArrayEventDispatcher(...args) {
			super();
			if (args.length==1 && args.length is int) {
				this._values = new Array( args[0] as int );
			} else {
				this._values = new Array();
				this._values.push.apply( this._values, args );
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
		private var _values:Array;

		/**
		 * @private
		 */
		private var _keys:Array;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @copy		Array#length
		 */
		public function get length():uint {
			return this._values.length;
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods: Proxy
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		flash_proxy final override function callProperty(name:*, ...rest):* {
			if ( super.flash_proxy::hasProperty(name) ) {
				rest.unshift(name);
				return super.flash_proxy::callProperty(name);
			} else {
				return this._values[name].apply(this._values, rest);
			}
		}

		/**
		 * @private
		 */
		flash_proxy final override function deleteProperty(name:*):Boolean {
			var result:Boolean = delete this._values[name];
			this.change();
			return result;
		}

		/*flash_proxy final override function getDescendants(name:*):* {
			return null;
		}*/

		/**
		 * @private
		 */
		flash_proxy final override function getProperty(name:*):* {
			if ( super.flash_proxy::hasProperty(name) ) {
				return super.flash_proxy::getProperty(name);
			} else {
				return this._values[name];
			}
		}

		/**
		 * @private
		 */
		flash_proxy final override function hasProperty(name:*):Boolean {
			return super.flash_proxy::hasProperty(name) || ( name in this._values );
		}

		/*flash_proxy final override function isAttribute(name:*):Boolean {
			return false;
		}*/

		/**
		 * @private
		 */
		flash_proxy final override function nextName(index:int):String {
			return this.getKeys()[ index - 1 ];
		}

		/**
		 * @private
		 */
		flash_proxy final override function nextNameIndex(index:int):int {
			return ( index < this.getKeys().length ? index+1 : 0 );
		}

		/**
		 * @private
		 */
		flash_proxy final override function nextValue(index:int):* {
			return this._values[ this.getKeys()[ index -1 ] ];
		}

		/**
		 * @private
		 */
		flash_proxy final override function setProperty(name:*, value:*):void {
			if ( this._values[name] === value ) return;
			this._values[name] = value;
			this.change();
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @copy		Array#concat()
		 */
		public function concat(...args):Array {
			return this._values.concat.apply( this._values, args );
		}

		/**
		 * @copy		Array#every()
		 */
		public function every(callback:Function, thisObject:*=null):Boolean  {
			return this._values.every( callback, thisObject );
		}

		/**
		 * @copy		Array#filter()
		 */
		public function filter(callback:Function, thisObject:*=null):Array  {
			return this._values.filter( callback, thisObject );
		}

		/**
		 * @copy		Array#forEach()
		 */
		public function forEach(callback:Function, thisObject:*=null):void  {
			this._values.forEach( callback, thisObject );
			this.change();
		}

		/**
		 * @copy		Array#indexOf()
		 */
		public function indexOf(searchElement:*, fromIndex:int=0):int  {
			return this._values.indexOf( searchElement, fromIndex );
		}

		/**
		 * @copy		Array#join()
		 */
		public function join(sep:*):String {
			return this._values.join( sep );
		}

		/**
		 * @copy		Array#lastIndexOf()
		 */
		public function lastIndexOf(searchElement:*, fromIndex:int=0x7FFFFFFF):int {
			return this._values.lastIndexOf( searchElement, fromIndex );
		}

		/**
		 * @copy		Array#map()
		 */
		public function map(callback:Function, thisObject:*=null):Array  {
			return this._values.map( callback, thisObject );
		}

		/**
		 * @copy		Array#pop()
		 */
		public function pop():*  {
			var result:* = this._values.pop();
			this.change();
			return result;
		}

		/**
		 * @copy		Array#push()
		 */
		public function push(...args):uint  {
			if (args.length>0) {
				var result:uint = this._values.push.apply( this._values, args );
				this.change();
				return result;
			} else {
				return this._values.length;
			}
		}

		/**
		 * @copy		Array#reverse()
		 */
		public function reverse():Array {
			return this._values.reverse();
		}

		/**
		 * @copy		Array#shift()
		 */
		public function shift():* {
			var result:* = this._values.shift();
			this.change();
			return result;
		}

		/**
		 * @copy		Array#slice()
		 */
		public function slice(startIndex:int=0, endIndex:int=16777215):Array {
			return this._values.slice( startIndex, endIndex );
		}

		/**
		 * @copy		Array#some()
		 */
		public function some(callback:Function, thisObject:*=null):Boolean {
			return this._values.some( callback, thisObject );
		}

		/**
		 * @copy		Array#sort()
		 */
		public function sort(...args):Array {
			var result:Array = this._values.sort.apply( this._values, args );
			this.change();
			return result;
		}

		/**
		 * @copy		Array#sortOn()
		 */
		public function sortOn(fieldName:Object, options:Object=null):Array {
			var result:Array = this._values.sort( fieldName, options );
			this.change();
			return result;
		}

		/**
		 * @copy		Array#splice()
		 */
		public function splice(startIndex:int, deleteCount:uint, ...values):Array {
			values.unshift( startIndex, deleteCount );
			var result:Array = this._values.splice.apply( this._values, values );
			this.change();
			return result;
		}

		/**
		 * @copy		Array#unshift()
		 */
		public function unshift(...args):uint {
			if (args.length>0) {
				var result:uint = this._values.unshift.apply( this._values, args );
				this.change();
				return result;
			} else {
				return this._values.length;
			}
		}

		/**
		 * @copy		Array#toString()
		 */
		public function toString():String {
			return ( this._values as Object ).toString();
		}

		/**
		 * Делает обычный массив.
		 */
		public function toArray():Array {
			return this._values.slice();
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function getKeys():Array {
			if (!this._keys) {
				this._keys = new Array();
				for ( var i:Object in this._values ) {
					this._keys.push( i );
				}
			}
			return this._keys;
		}

		/**
		 * @private
		 */
		private function change():void {
			this._keys = null;
			super.dispatchEvent( new Event( Event.CHANGE ) );
		}

	}

}