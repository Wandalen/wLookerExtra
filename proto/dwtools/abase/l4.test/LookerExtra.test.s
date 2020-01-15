( function _LookerExtra_test_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = require( '../../Tools.s' );

  require( '../l4/LookerExtra.s' );

  _.include( 'wTesting' );

}

var _global = _global_;
var _ = _global_.wTools;

// --
// tests
// --

function entitySearch( test )
{

  test.case = '2 arguments';
  var src = { a : 0, e : { d : 'something' } };
  var got = _.entitySearch( src, 'something' );
  var exp = { '/e/d' : 'something' };
  test.identical( got, exp );

  test.case = 'options map';
  var src = { a : 0, e : { d : 'something' } };
  var got = _.entitySearch({ src : src, ins : 'something' });
  var exp = { '/e/d' : 'something' };
  test.identical( got, exp );

  test.case = 'returning : src';
  var src = { a : 0, e : { d : 'something' } };
  var got = _.entitySearch({ src : src, ins : 'something', returning : 'src' });
  var exp = { '/e/d' : 'something' };
  test.identical( got, exp );

}

//

function entitySearchReturningSrc( test )
{

  test.case = 'trivial';
  var src = { a : 0, e : { d : 'something' } };
  var exp = { '/e/d' : 'something' };
  var got = _.entitySearch({ src : src, ins : 'something', returning : 'src' });
  test.contains( got, exp );

}

//

function entitySearchReturningIt( test )
{

  test.case = 'trivial';
  var src = { a : 0, e : { d : 'something' } };
  var exp =
  [
    {
      'childrenCounter' : 0,
      'level' : 2,
      'path' : '/e/d',
      'key' : 'd',
      'index' : 0,
      'src' : 'something',
      'continue' : true,
      'ascending' : false,
      'revisited' : false,
      '_' : null,
      'down' :
      {
        'childrenCounter' : 1,
        'level' : 1,
        'path' : '/e',
        'key' : 'e',
        'index' : 1,
        'src' : src.e,
        'continue' : true,
        'ascending' : false,
        'revisited' : false,
        '_' : null,
        'visiting' : true,
        'iterable' : 'map-like',
        'visitCounting' : true
      },
      'visiting' : true,
      'iterable' : false,
      'visitCounting' : true
    }
  ]
  var got = _.entitySearch({ src : src, ins : 'something', returning : 'it' });
  test.contains( got, exp );

}

//

function entitySearchOptionPathJoin( test )
{
  let ups = [];
  let dws = [];
  let structure =
  {
    int : 0,
    str : 'str',
    arr : [ 1, 3 ],
    map : { m1 : new Date( Date.UTC( 1990, 0, 0 ) ), m3 : 'str' },
    set : new Set([ 1, 3 ]),
    hash : new HashMap([ [ new Date( Date.UTC( 1990, 0, 0 ) ), function(){} ], [ 'm3', 'str' ] ]),
  }

  /* - */

  test.case = 'basic';
  clean();
  var found = _.entitySearch
  ({
    src : structure,
    ins : 'str',
    onPathJoin : onPathJoin,
  });
  var exp =
  {
    '/String::str' : 'str',
    '/Object::map/String::m3' : 'str',
    '/Map::hash/String::m3' : 'str',
  }
  test.identical( found, exp );

  /* - */

  function clean()
  {
    ups.splice( 0, ups.length );
    dws.splice( 0, dws.length );
  }

  function onPathJoin( selectorPath, upToken, defaultUpToken, selectorName )
  {
    let it = this;
    let result;

    _.assert( arguments.length === 4 );

    if( _.strEnds( selectorPath, upToken ) )
    {
      result = selectorPath + _.strType( it.src ) + '::' + selectorName;
    }
    else
    {
      result = selectorPath + defaultUpToken + _.strType( it.src ) + '::' + selectorName;
    }

    return result;
  }

}

// --
// declare
// --

var Self =
{

  name : 'Tools.base.l4.LookerExtra',
  silencing : 1,
  enabled : 1,

  context :
  {
  },

  tests :
  {

    entitySearch,
    entitySearchReturningSrc,
    entitySearchReturningIt,
    entitySearchOptionPathJoin,

  }

}

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
