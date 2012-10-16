////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils.ui {

	import flash.display.InteractiveObject;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;

	/**
	 * Вспомогательный класс для работы с контекстным меню.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					contextmenuutils, contextmenu, contextmenuitem, contextmenubuiltinitems
	 * 
	 * @see						flash.display.InteractiveObject#contextMenu 
	 * @see						flash.ui.ContextMenu
	 */
	public final class ContextMenuUtils {

		/**
		 * Ищет билижайшее меню по родителям.
		 * 
		 * @param	child			Объект меню, которого надо найти.
		 * 
		 * @return					Контекстное меню.
		 * 
		 * @keyword					contextmenuutils.getcontextmenu, getcontextmenu
		 */
		public static function getContextMenu(child:InteractiveObject, separatorBefore:Boolean=false):ContextMenu {
			var items:Array;
			var i:uint;

			do {
				// О! у нашего предка есть менюшка
				if ( child.contextMenu ) {
					var menu:ContextMenu = child.contextMenu.clone();
					items = child.contextMenu.customItems;
					menu.customItems.length = 0;

					for ( i=0; i < items.length; ++i ) {
						menu.customItems[i] = child.contextMenu.customItems[i];
					}

					if (separatorBefore) {
						items = menu.customItems;

						for ( i=0; i<items.length; ++i ) {
							if ( ( items[i] as ContextMenuItem ).visible ) {
								( items[i] as ContextMenuItem ).separatorBefore = true;
								break;
							}
						}
					}
					return menu;
				}
			} while ( child = child.parent );
			// ничё не нашли
			return null;
		}

	}

}