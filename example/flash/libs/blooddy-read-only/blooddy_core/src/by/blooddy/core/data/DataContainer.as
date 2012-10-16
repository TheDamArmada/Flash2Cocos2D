////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.data {

	//--------------------------------------
	//  Namespaces
	//--------------------------------------
	
	use namespace $internal;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					datacontainer, data
	 */
	public class DataContainer extends Data {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor.
		 */
		public function DataContainer() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _list:Array = new Array();

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  numChildren
		//----------------------------------

		/**
		 * Возвращает количество детей.
		 * 
		 * @keyword					datacontainer.numchildren, numchildren
		 */
		public function get numChildren():int {
			return this._list.length;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  addChild
		//----------------------------------

		/**
		 * Добавляет новое дитё.
		 * 
		 * @param	child			Дитё на добавление.
		 * 
		 * @return					Возвращает добавленное дитё.
		 * 
		 * @event	added			
		 * 
		 * @throws	ArgumentError	Самого сибя добавляем, или добавляем дитё, которое является нашим предком.
		 * 
		 * @keyword					datacontainer.addchild, addchild
		 */
		public function addChild(child:Data):Data {
			if ( !child ) Error.throwError( TypeError, 2007, 'child' );
			if ( child === this ) Error.throwError( ArgumentError, 2024 );
			if ( child.$parent === this ) {
				this.$setChildIndex( child, this._list.length );
				return child;
			} else {
				if ( child is DataContainer && ( child as DataContainer ).$contains( this ) ) {
					Error.throwError( ArgumentError, 2150 );
				}
				return this.$addChildAt( child, this._list.length );
			}
		}

		//----------------------------------
		//  addChildAt
		//----------------------------------

		/**
		 * Добавляет новое дитё в конкретное место.
		 * 
		 * @param	child			Дитё на добавление.
		 * @param	index			Индекс элемента.
		 * 
		 * @return					Возвращает добавленное дитё.
		 * 
		 * @throws	RangeError		Куда-то не туда вставляем :(
		 * @throws	ArgumentError	Самого сибя добавляем, или добавляем дитё, которое является нашим предком.
		 * 
		 * @keyword					datacontainer.addchildat, addchildat
		 */
		public function addChildAt(child:Data, index:int):Data {
			if ( !child ) Error.throwError( TypeError, 2007, 'child' );
			if ( index < 0 || index > this._list.length ) Error.throwError( RangeError, 2006 );
			if ( child === this ) Error.throwError( ArgumentError, 2024 );
			if ( child.$parent === this ) {
				this.$setChildIndex( child, index );
				return child;
			} else {
				if ( child is DataContainer && ( child as DataContainer ).$contains( this ) ) {
					Error.throwError( ArgumentError, 2150 );
				}
				return this.$addChildAt( child, index );
			}
		}

		/**
		 * @private
		 */
		private function $addChildAt(child:Data, index:int):Data {
			var parent:DataContainer = child.$parent;
			if ( parent ) {
				parent.$removeChildAt( parent._list.indexOf( child ) );
			}
			this._list.splice( index, 0, child );
			this.addChild_before( child );
			child.$setParent( this );
			return child;
		}

		//----------------------------------
		//  removeChild
		//----------------------------------

		/**
		 * Удаляет дитё.
		 * 
		 * @param	child			Дитё на удаление.
		 * 
		 * @return					Возвращает удалённое дитё.
		 * 
		 * @throws	ArgumentError	Пытаемся удалить дитё не лежащие в нас.
		 * 
		 * @keyword					datacontainer.removechild, removechild
		 */
		public function removeChild(child:Data):Data {
			if ( !child ) Error.throwError( TypeError, 2007, 'child' );
			if ( child.$parent !== this ) Error.throwError( ArgumentError, 2025 );
			return this.$removeChildAt( this._list.indexOf( child ) );
		}

		//----------------------------------
		//  removeChildAt
		//----------------------------------

		/**
		 * Удаляет дитё из конкретного места.
		 * 
		 * @param	index			Место.
		 * 
		 * @return					Возвращает удалённое дитё.
		 * 
		 * @throws	RangeError		Нету такой ячейки :(
		 * 
		 * @keyword					datacontainer.removechildat, removechildat
		 */
		public function removeChildAt(index:int):Data {
			if ( index < 0 || index >= this._list.length ) Error.throwError( RangeError, 2006 );
			return this.$removeChildAt( index );
		}

		/**
		 * @private
		 */
		private function $removeChildAt(index:int):Data {
			var child:Data = this._list.splice( index, 1 )[ 0 ];
			this.removeChild_before( child ); // вызовем событие о добавлние
			child.$setParent( null );
			return child;
		}

		//----------------------------------
		//  removeChildren
		//----------------------------------
		
		public function removeChildren(beginIndex:int=0, endIndex:int=int.MAX_VALUE):void {
			if ( arguments.length < 2 ) endIndex = this._list.length;
			else ++endIndex;
			var l:int = endIndex - beginIndex;
			if ( l < 0 || beginIndex < 0 || endIndex > this._list.length ) Error.throwError( RangeError, 2006 );
			if ( l > 0 ) {
				for each( var child:Data in this._list.splice( beginIndex, l ) ) {
					this.removeChild_before( child );
					child.$setParent( null );
				}
			}
		}
		
		//----------------------------------
		//  contains
		//----------------------------------

		/**
		 * Проверяет наличие дити.
		 * 
		 * @param	child			Дитё для проверки.
		 * 
		 * @return					Возвращает true, если нашли такое.
		 * 
		 * @keyword					datacontainer.contains, contains
		 */
		public function contains(child:Data):Boolean {
			if ( !child ) Error.throwError( TypeError, 2007, 'child' );
			return this.$contains( child );
		}

		/**
		 * @private
		 */
		private function $contains(child:Data):Boolean {
			do {
				if ( child === this ) return true;
			} while ( child = child.$parent );
			return false;
		}

		//----------------------------------
		//  getChildAt
		//----------------------------------

		/**
		 * Ищет дитё в конкретном месте.
		 * 
		 * @param	index			Индекс.
		 * 
		 * @return					Возвращает найденное дитё.
		 * 
		 * @throws	RangeError		Нету такой ячейки :(
		 * 
		 * @keyword					datacontainer.getchildat, getchildat
		 */
		public function getChildAt(index:int):Data {
			if ( index < 0 || index >= this._list.length ) Error.throwError( RangeError, 2006 );
			return this._list[ index ];
		}

		//----------------------------------
		//  getChildByName
		//----------------------------------

		/**
		 * Ищет дитё с конкретным name.
		 * 
		 * @param	name			name
		 * 
		 * @return					Возвращает найденное дитё или null.
		 * 
		 * @keyword					datacontainer.getchildbyid, getchildbyid
		 * 
		 * @see						by.blooddy.core.data.Data#id
		 */
		public function getChildByName(name:String):Data {
			for each ( var child:Data in this._list ) {
				if ( child.name === name ) return child;
			}
			return null;
		}

		//----------------------------------
		//  getChildIndex
		//----------------------------------

		/**
		 * Возвращает index конкретного дити.
		 * 
		 * @param	child			Наше дитё.
		 * 
		 * @return					Возвращает индекс дити или -1.
		 * 
		 * @throws	ArgumentError	Не наше дитё!
		 * 
		 * @keyword					datacontainer.getchildindex, getchildindex
		 */
		public function getChildIndex(child:Data):int {
			if ( !child ) Error.throwError( TypeError, 2007, 'child' );
			if ( child.$parent !== this ) Error.throwError( ArgumentError, 2025 );
			return this._list.indexOf( child );
		}

		//----------------------------------
		//  setChildIndex
		//----------------------------------

		/**
		 * Присваивает новый индекс дитю.
		 * 
		 * @param	child			Наше дитё.
		 * @param	index			Новое место.
		 * 
		 * @throws	RangeError		Нету такой ячейки :(
		 * @throws	ArgumentError	Не наше дитё!
		 * 
		 * @keyword					datacontainer.setchildindex, setchildindex
		 */
		public function setChildIndex(child:Data, index:int):void {
			if ( !child ) Error.throwError( TypeError, 2007, 'child' );
			if ( index < 0 || index >= this._list.length ) Error.throwError( RangeError, 2006 );
			this.$setChildIndex( child, index );
		}

		/**
		 * @private
		 */
		private function $setChildIndex(child:Data, index:int):void {
			var i:int = this._list.indexOf( child );
			if ( i != index ) {
				this._list.splice( i, 1 );
				this._list.splice( index, 0, child );
			}
		}

		//----------------------------------
		//  swapChildren
		//----------------------------------

		/**
		 * Меняем местами 2х дитей.
		 * 
		 * @param	child1			Первое дитё.
		 * @param	child2			Второе дитё.
		 * 
		 * @throws	ArgumentError	Один из детей не наш :(
		 * 
		 * @keyword					datacontainer.swapchildren, swapchildren
		 */
		public function swapChildren(child1:Data, child2:Data):void {
			if ( !child1 ) Error.throwError( TypeError, 2007, 'child1' );
			if ( !child2 ) Error.throwError( TypeError, 2007, 'child2' );
			if ( child1.$parent !== this || child2.$parent !== this ) Error.throwError( ArgumentError, 2025 );
			this.$swapChildrenAt(
				child1,
				child2,
				this._list.indexOf( child1 ),
				this._list.indexOf( child2 )
			);
		}

		//----------------------------------
		//  swapChildrenAt
		//----------------------------------

		/**
		 * Меняем местами 2х дитей по идексам.
		 * 
		 * @param	index1			Первый индекс.
		 * @param	index2			Второй индекс.
		 * 
		 * @throws	RangeError		Нету такой ячейки :(
		 * 
		 * @keyword					datacontainer.swapchildrenat, swapchildrenat
		 */
		public function swapChildrenAt(index1:int, index2:int):void {
			if ( index1 < 0 || index1 >= this._list.length || index2 < 0 || index2 >= this._list.length ) Error.throwError( RangeError, 2006 );
			this.$swapChildrenAt(
				this._list[ index1 ],
				this._list[ index2 ],
				index1,
				index2
			);
		}

		/**
		 * @private
		 */
		private function $swapChildrenAt(child1:Data, child2:Data, index1:int, index2:int):void {
			this._list.splice( index1, 1, child2 );
			this._list.splice( index2, 1, child1 );
		}

		//----------------------------------
		//  sort
		//----------------------------------

		/**
		 * Сортировка детей.
		 * 
		 * @see						Array#sort()
		 */
		public function sort(...args):void {
			this._list.sort.apply(this._list, args);
		}

		//----------------------------------
		//  sortOn
		//----------------------------------

		/**
		 * Сортировка детей.
		 * 
		 * @see						Array#sortOn()
		 */
		public function sortOn(fieldName:Object, options:Object=null):void {
			this._list.sortOn( fieldName, options );
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		protected function addChild_before(child:Data):void {
		}

		protected function removeChild_before(child:Data):void {
		}

	}

}