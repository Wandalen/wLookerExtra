
let _ = require( 'wlookerextra' )
var src = { a : 0, e : { d : 'something' } };
var got = _.entity.search( src, 'something' );
console.log( got );

/*
  { '/e/d': 'something' }
*/
