/*!
 * blooddy/events.js
 * © 2009 BlooDHounD
 * @author BlooDHounD <http://www.blooddy.by>
 */

if ( !window.blooddy ) throw new Error( '"blooddy" not initialized' );

if ( !blooddy.events ) {

	/**
	 * @package
	 * @final
	 * @namespace	blooddy
	 * @author		BlooDHounD	<http://www.blooddy.by>
	 */
	blooddy.events = blooddy.createAbstractInstance( 'events' );

}