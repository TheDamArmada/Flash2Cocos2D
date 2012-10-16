////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net.connection.filters {

	import by.blooddy.core.commands.Command;
	import by.blooddy.core.net.NetCommand;
	import by.blooddy.core.utils.xml.IXMLable;
	import by.blooddy.crypto.MD5;
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					09.09.2009 22:25:41
	 */
	public class SincereSocketFilter implements ISocketFilter, IXMLable {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _JUNK:ByteArray = new ByteArray();

		//--------------------------------------------------------------------------
		//
		//  Class contants
		//
		//--------------------------------------------------------------------------

		public static const TYPE_BOOLEAN:String =	'boolean';

		public static const TYPE_INT8:String =		'int8';

		public static const TYPE_UINT8:String =		'uint8';

		public static const TYPE_INT16:String =		'int16';

		public static const TYPE_UINT16:String =	'uint16';

		public static const TYPE_INT32:String =		'int32';

		public static const TYPE_UINT32:String =	'uint32';

		public static const TYPE_FLOAT:String =		'float';

		public static const TYPE_DOUBLE:String =	'double';

		public static const TYPE_STRING:String =	'string';

		public static const TYPE_BYTES:String =		'bytes';

		public static const TYPE_ARRAY:String =		'array';

		public static const TYPE_COMMAND:String =	'command';

		public static const TYPE_STRUCTURE:String =	'structure';
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function SincereSocketFilter() {
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
		private var _hash:String;
		
		/**
		 * @private
		 */
		private const _input_patterns:Object = new Object();

		/**
		 * @private
		 */
		private const _output_patterns:Object = new Object();

		/**
		 * @private
		 * хэш контекстов.
		 * на случай, если одним сериализатором пользуются несколько сокетов.
		 */
		private const _contexts:Dictionary = new Dictionary( true );

		//--------------------------------------------------------------------------
		//
		//  Implements methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function getHash():String {
			return this._hash;
		}

		public function isSystem(commandName:String, io:String=NetCommand.UNKNOWN):Boolean {
			var command:Command;
			switch ( io ) {
				case NetCommand.INPUT:	command = this._input_patterns[ commandName ];	break;
				case NetCommand.OUTPUT:	command = this._output_patterns[ commandName ];	break;
				default:				command = null;									break;
			}
			return ( command && command.system );
		}
		
		/**
		 * @inheritDoc
		 */
		public function readCommand(input:IDataInput, io:String=NetCommand.INPUT):NetCommand {

			var context:Context = this._contexts[ input ] as Context;
			if ( !context ) this._contexts[ input ] = context = new Context();

			if ( !context.pattern ) { // нет комманды в процессе чтения
				var header:Vector.<uint> = context.header;
				do {
					// сперва проверим, биты синхронизации
					while ( header.length < 7 ) {
						if ( input.bytesAvailable < 1 ) return null; // не хватает данных. ждём.
						header.push( input.readUnsignedByte() );
					}
					if ( // валидация
						         header[ 0 ] & 0x57   != 0x57							||	// 01010111 != 01010111
						Boolean( header[ 0 ] & 0x08 ) == Boolean( header[ 1 ] & 0x80 )	||	// 00001000 != 10000000
						Boolean( header[ 0 ] & 0x20 ) == Boolean( header[ 3 ] & 0x80 )	||	// 00100000 != 10000000
						Boolean( header[ 0 ] & 0x80 ) == Boolean( header[ 3 ] & 0x40 )		// 10000000 != 01000000
					) { // если не валиден, что удаляем предыдущий элемент
						header.shift(); // TODO: throw new Error()
					}
				} while ( header.length < 7 );
				// высчитываем значения
				var id:uint =		( header[ 1 ] & 0x7F ) <<  8 | header[ 2 ];
				var length:uint =	( header[ 3 ] & 0x3F ) << 24 | header[ 4 ] << 16 | header[ 5 ] << 8 | header[ 6 ];

				// очищаем значения хедера
				header.splice( 0, header.length );

				// сохранили контекст
				switch ( io ) {
					case NetCommand.INPUT:	context.pattern = this._input_patterns[ id ];	break;
					case NetCommand.OUTPUT:	context.pattern = this._output_patterns[ id ];	break;
					default:				throw new ArgumentError( 'неизвестный тип комманды: ' + io );
				}

				if ( !context.pattern ) { // такой комманды не зарегестрированно
					if ( input.bytesAvailable > 0 ) { // вычитаем данные, которые можем, что бы потом в халастую не гонять
						input.readBytes( _JUNK, 0, Math.min( input.bytesAvailable, length ) );
						_JUNK.length = 0;
					}
					throw new ArgumentError( 'неизвестный id команды: ' + id );
				}

				context.length = length;

			}

			if ( input.bytesAvailable < context.length ) return null;	// не хвататет данных для чтения комманды

			var bytes:ByteArray = new ByteArray();

			try {

				if ( context.length ) { // а надо ли вообще что-то читать ещё?
					input.readBytes( bytes, 0, context.length );
					context.length = 0;
					if ( context.pattern.zipped ) { // расзиповали
						bytes.uncompress();
					}
				}
	
				var command:NetCommand = new NetCommand( context.pattern.name, io );
				command.system = context.pattern.system;
				var l:uint = context.pattern.length;
				for ( var i:uint = 0; i<l; ++i ) {
					command.push(
						this.readType(
							bytes,
							context.pattern[ i ] as TypeDescription,
							io
						)
					);
				}

				if ( bytes.bytesAvailable ) { // в буфере остались данные. говно.
					throw new ArgumentError( 'в конце прочитанной команды остался мусор: ' + bytes.bytesAvailable );
				}

				return command;

			} finally {

				context.pattern = null;
				bytes.clear(); // очищаем прочитанное

			}

			return null;
		}

		/**
		 * @inheritDoc
		 */
		public function writeCommand(output:IDataOutput, command:NetCommand):void {

			var pattern:NetCommandPattern;
			switch ( command.io ) {
				case NetCommand.INPUT:	pattern = this._input_patterns[ command.name ];		break;
				case NetCommand.OUTPUT:	pattern = this._output_patterns[ command.name ];	break;
				default:				throw new ArgumentError( 'неизвестный тип комманды: ' + command.io );
			}

			var bytes:ByteArray = new ByteArray();

			try {

				// записываем комманду
				var l:uint = pattern.length;
				for ( var i:uint = 0; i<l; ++i ) {
					this.writeType( bytes, pattern[ i ], command[ i ], command.io );
				}

				if ( bytes.length > 0 && pattern.zipped ) { // зипуем
					bytes.compress();
				}

				// записываем заголовок
				var id:uint = pattern.id;
				var length:uint = bytes.length;
				var sync:uint = 0x57;
	
				if ( Math.random() > 0.5 ) {
					sync	|= 0x80;
				} else {
					id		|= 0x8000;
				}
				if ( Math.random() > 0.5 ) {
					sync	|= 0x20;
				} else {
					length	|= 0x40000000;
				}
				if ( Math.random() > 0.5 ) {
					sync	|= 0x08;
				} else {
					length	|= 0x80000000;
				}
				output.writeByte( sync );
				// записали идэшник
				output.writeShort( id );
				// записали длинну
				output.writeUnsignedInt( length );
				// сам пакет
				output.writeBytes( bytes );

			} finally {

				bytes.clear(); // очищаем записанное

			}

		}

		/**
		 * @inheritDoc
		 */
		public function parseXML(xml:XML):void {

			var children:XMLList = xml.*.( localName() == 'command' );
			var pattern:NetCommandPattern;
			for each ( var x:XML in children ) {
				pattern = new NetCommandPattern();
				pattern.parseXML( x );
				if ( !pattern.id ) throw new ArgumentError( 'не укзан id для комманды' );
				if ( !pattern.name ) throw new ArgumentError( 'не укзан name для комманды' );
				switch ( pattern.io ) {

					case NetCommand.INPUT:
						if ( pattern.name in this._input_patterns ) throw new ArgumentError( 'дублирование name в input_patterns: ' + pattern.name );
						if ( pattern.id in this._input_patterns ) throw new ArgumentError( 'дублирование id в input_patterns: ' + pattern.id );
						this._input_patterns[ pattern.name ] =	pattern;
						this._input_patterns[ pattern.id ] =	pattern;
						break;

					case NetCommand.OUTPUT:
						if ( pattern.name in this._output_patterns ) throw new ArgumentError( 'дублирование name в output_patterns: ' + pattern.name );
						if ( pattern.id in this._output_patterns ) throw new ArgumentError( 'дублирование id в output_patterns: ' + pattern.id );
						this._output_patterns[ pattern.name ] =	pattern;
						this._output_patterns[ pattern.id ] =	pattern;
						break;

					default:
						throw new ArgumentError( 'неизветсный namespace команды: ' + pattern.io );

				}
			}

			// считаем хэш
			
			var ignoreComments:Boolean = XML.ignoreComments;
			var ignoreProcessingInstructions:Boolean = XML.ignoreProcessingInstructions;
			var ignoreWhitespace:Boolean = XML.ignoreWhitespace;
			var prettyPrinting:Boolean = XML.prettyPrinting;
			XML.ignoreComments = true;
			XML.ignoreProcessingInstructions = true;
			XML.ignoreWhitespace = true;
			XML.prettyPrinting = false;

			xml = xml.copy();
			var a:Array = new Array();
			children = xml.children();
			for each ( x in children ) {
				a.push( x );
			}
			a.sortOn( '@id', Array.NUMERIC );
			var l:uint = a.length;
			for ( var i:uint = 0; i<l; ++i ) {
				children[ i ] = a[ i ];
			}
			
			xml.setChildren( children );

			XML.ignoreComments = ignoreComments;
			XML.ignoreProcessingInstructions = ignoreProcessingInstructions;
			XML.ignoreWhitespace = ignoreWhitespace;
			XML.prettyPrinting = prettyPrinting;

			this._hash = MD5.hash( xml.toXMLString() );
			
		}

		/**
		 * @inheritDoc
		 */
		public function toXML():XML {
			var result:XML = <protocol />;
			result.addNamespace( new Namespace( NetCommand.INPUT, NetCommand.INPUT ) );
			result.addNamespace( new Namespace( NetCommand.OUTPUT, NetCommand.OUTPUT ) );
			var hash:Dictionary = new Dictionary();
			var pattern:NetCommandPattern;
			for each ( pattern in this._input_patterns ) {
				if ( pattern in hash ) continue;
				hash[ pattern ] = true;
				result.appendChild( pattern.toXML() );
			}
			for each ( pattern in this._output_patterns ) {
				if ( pattern in hash ) continue;
				hash[ pattern ] = true;
				result.appendChild( pattern.toXML() );
			}
			return result;
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function readType(input:IDataInput, desc:TypeDescription, io:String):* {
			var l:uint;
			switch ( desc.type ) {
				case TYPE_BOOLEAN:	return input.readBoolean();
				case TYPE_INT8:		return input.readByte();
				case TYPE_UINT8:	return input.readUnsignedByte();
				case TYPE_INT16:	return input.readShort();
				case TYPE_UINT16:	return input.readUnsignedShort();
				case TYPE_INT32:	return input.readInt();
				case TYPE_UINT32:	return input.readUnsignedInt();
				case TYPE_FLOAT:	return input.readFloat();
				case TYPE_DOUBLE:	return input.readDouble();
				case TYPE_STRING:
					if ( desc.length ) {
						return input.readUTFBytes( desc.length );
					} else {
						return input.readUTF();
					}
				case TYPE_BYTES:
					if ( desc.length ) {
						l = desc.length;
					} else {
						l = input.readUnsignedShort();
					}
					var bytes:ByteArray = new ByteArray();
					if ( l > 0 ) {
						input.readBytes( bytes, 0, l );
					}
					return bytes;
				case TYPE_STRUCTURE:
					
				case TYPE_ARRAY:
					if ( !desc.included ) throw new ArgumentError( 'для массива, должен всегда передоваться тип данных' );
					if ( desc.length ) {
						l = desc.length;
					} else {
						l = input.readUnsignedShort();
					}
					var arr:Array = new Array();
					for ( var i:uint = 0; i<l; ++i ) {
						arr.push( this.readType( input, desc.included, io ) );
					}
					return arr;
				case TYPE_COMMAND:
					return this.readCommand( input, io );
			}
			throw new ArgumentError( 'произошла попытка прочитать неизвестный тип данных: ' + desc.type );
		}

		/**
		 * @private
		 */
		private function writeType(output:IDataOutput, desc:TypeDescription, value:*, io:String):void {
			switch ( desc.type ) {
				case TYPE_BOOLEAN:	output.writeBoolean( value );		break;
				case TYPE_INT8:
				case TYPE_UINT8:	output.writeByte( value );			break;
				case TYPE_INT16:
				case TYPE_UINT16:	output.writeShort( value );			break;
				case TYPE_INT32:	output.writeInt( value );			break;
				case TYPE_UINT32:	output.writeUnsignedInt( value );	break;
				case TYPE_FLOAT:	output.writeFloat( value );			break;
				case TYPE_DOUBLE:	output.writeDouble( value );		break;
				case TYPE_STRING:
					if ( desc.length ) {
						if ( ( value as String ).length != desc.length ) throw new ArgumentError( 'длинна строки не соответсвует заявленной в шаблоне: ' + ( value as String ).length + ' => ' + desc.length );
						output.writeUTFBytes( value );
					} else {
						output.writeUTF( value );
					}
					break;
				case TYPE_BYTES:
					if ( desc.length ) {
						if ( ( value as ByteArray ).length != desc.length ) throw new ArgumentError( 'длинна масива байт не соответсвует заявленной в шаблоне: ' + ( value as ByteArray ).length + ' => ' + desc.length );
					} else {
						output.writeShort( ( value as ByteArray ).length );
					}
					output.writeBytes( value );
					break;
				case TYPE_ARRAY:
					if ( !desc.included ) throw new ArgumentError( 'в массиве обазательно должен передавать конечный тип данных' );
					var arr:Array = value as Array;
					var l:uint;
					l = arr.length;
					if ( desc.length ) {
						if ( l != desc.length ) throw new ArgumentError( 'длинна массива не соответсвует заявленной в шаблоне: ' + ( value as Array ).length + ' => ' + desc.length );
					} else {
						output.writeShort( l );
					}
					for ( var i:uint = 0; i<l; ++i ) {
						this.writeType( output, desc.included, arr[ i ], io );
					}
					break;
				case TYPE_COMMAND:
					if ( !( value is NetCommand ) ) {
						value = new NetCommand( ( value as Command ).name, io, value );
					}
					this.writeCommand( output, value );
					break;
				default:
					throw new ArgumentError( 'произошла попытка записать неизвеcтного типа данных: ' + desc.type );
			}
		}

	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import by.blooddy.core.net.NetCommand;
import by.blooddy.core.utils.xml.IXMLable;
import by.blooddy.core.utils.xml.XMLUtils;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: EventContainer
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 */
internal final class Context {

	public function Context() {
		super();
	}

	public const header:Vector.<uint> = new Vector.<uint>();

	public var pattern:NetCommandPattern;

	public var length:uint;

}

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: NetCommandPattern
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 */
internal final dynamic class NetCommandPattern extends NetCommand implements IXMLable {

	public function NetCommandPattern() {
		super( '' );
	}

	public var id:uint = 0;

	public var zipped:Boolean = false;

	public function toXML():XML {
		var result:XML = <command />;
		result.setNamespace( this.io );
		result.@name =	super.name;
		result.@id =	this.id;
		if ( this.zipped ) result.@zipped = this.zipped;
		if ( this.system ) result.@system = this.system;
		var l:uint = super.length;
		for ( var i:uint = 0; i<l; ++i ) {
			result.appendChild( ( this[ i ] as TypeDescription ).toXML() ); 
		}
		return result;
	}

	public function parseXML(xml:XML):void {
		super.io =		xml.namespace().prefix;
		super.name =	xml.@name;
		this.id =		XMLUtils.parseListToInt( xml.@id );
		this.zipped =	XMLUtils.parseListToBoolean( xml.@zipped );
		this.system =	XMLUtils.parseListToBoolean( xml.@system );
		var list:XMLList = xml.value;
		var type:TypeDescription;
		for each ( xml in list ) {
			type = new TypeDescription();
			type.parseXML( xml );
			super.push( type );
		}
	}

}

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: TypeDescription
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 */
internal final class TypeDescription implements IXMLable {

	public function TypeDescription() {
		super();
	}

	public var name:String;

	public var type:String;

	public var length:uint;

	public var included:TypeDescription;

	public function toXML():XML {
		var result:XML = <value />;
		result.@name =		this.name;
		result.@type =		this.type;
		if ( this.length ) result.@length = this.length;
		if ( this.included ) result.appendChild( this.included.toXML() );
		return result;
	}

	public function parseXML(xml:XML):void {
		this.name =		XMLUtils.parseListToString( xml.@name );
		this.type =		XMLUtils.parseListToString( xml.@type );
		this.length =	XMLUtils.parseListToInt( xml.@length );
		var list:XMLList = xml.value;
		if ( list.length() > 0 ) {
			this.included = new TypeDescription();
			this.included.parseXML( list[ 0 ] );
		}
	}

}