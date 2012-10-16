////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import by.blooddy.core.net.connection.IAbstractConnection;

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * начали соеденяться с ервером.
	 *
	 * @eventType				flash.events.EventEvent.CONNECT
	 */
	[Event( name="open", type="flash.events.Event" )]

	/**
	 * Устанавилось соединение с сервером.
	 *
	 * @eventType				flash.events.EventEvent.CONNECT
	 */
	[Event( name="connect", type="flash.events.Event" )]

	/**
	 * Соединение разорвалось, по какой-то ошибке, или со стороны сервера.
	 *
	 * @eventType				flash.events.EventEvent.CLOSE
	 */
	[Event( name="close", type="flash.events.Event" )]

	/**
	 * Ошибка :)
	 *
	 * @eventType				flash.events.IOErrorEvent.IO_ERROR
	 */
	[Event( name="ioError", type="flash.events.IOErrorEvent" )]

	/**
	 * Секъюрная ошибка. Обращение запрещено со стороны сервера.
	 *
	 * @eventType				flash.events.SecurityErrorEvent.SECURITY_ERROR
	 */
	[Event( name="securityError", type="flash.events.SecurityErrorEvent" )]	

	/**
	 * IAbstractSocket является интерфейсом для любых типов сокетных сединений,
	 * или их эмуляций.
	 *
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					isocketasset, socket
	 */
	public interface IAbstractSocket extends IAbstractConnection {

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  protocol
		//----------------------------------

		/**
		 * Тип протокола.
		 *
		 * @keyword					socket.protocol, protocol
		 *
		 * @see						by.blooddy.core.net.Protocols
		 */
		function get protocol():String;

		//----------------------------------
		//  host
		//----------------------------------

		/**
		 * Хост, к которому конектимся.
		 *
		 * @keyword					socket.host, host
		 */
		function get host():String;

		//----------------------------------
		//  port
		//----------------------------------

		/**
		 * Порт, по которому конектимся.
		 *
		 * @keyword					socket.port, port
		 */
		function get port():int;

		//----------------------------------
		//  timeout
		//----------------------------------

		/**
		 * Порт, по которому конектимся.
		 *
		 * @keyword					socket.port, port
		 */
		function get timeout():uint;

		/**
		 * @private
		 */
		function set timeout(value:uint):void;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * Устанавливает соединение.
		 * 
		 * После установки соединения значение переменной connected
		 * должно уставновится в true
		 * 
		 * @param	host			Домен, которому будем конектиться.
		 * @param	port			Порт, которому будем конектиться.
		 * 
		 * @event	securityError	flash.events.SecurityErrorEvent
		 * @event	connect			flash.events.Event
		 * 
		 * @throws	SecurityError	флэшки нету доступа к домену.
  		 * @throws	SecurityError	пытаемся конектиться выше порта 65535.  
		 * 
		 * @keyword					socket.connect, connect
		 * 
		 * @see						flash.events.Event#CONNECT
		 * @see						#close()
		 */
		function connect(host:String, port:int):void;

		/**
		 * Закрываем соединение.
		 * 
		 * @event	close			flash.events.Event
		 * 
		 * @keyword					socket.close, close
		 * 
		 * @see						#connected
		 * @see						#connect()
		 */
		function close():void;

	}

}