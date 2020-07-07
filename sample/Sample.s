
let _ = require( 'wlookerextra' )
var src = { a : 0, e : { d : 'something' } };
var got = _.entitySearch( src, 'something' );
console.log( got );

/*
  { '/e/d': 'something' }
*/
