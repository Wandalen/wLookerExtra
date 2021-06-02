( function _LookerExtra_test_s_()
{

'use strict';

if( typeof module !== 'undefined' )
{
  const _ = require( '../../../node_modules/Tools' );

  require( '../l4/LookerExtra.s' );

  _.include( 'wTesting' );
}

const _global = _global_;
const _ = _global_.wTools;
const Parent = _.looker.Looker;

// --
// tests
// --

function entitySearch( test )
{

  test.case = '2 arguments';
  var src = { a : 0, e : { d : 'something' } };
  var got = _.entity.search( src, 'something' );
  var exp = { '/e/d' : 'something' };
  test.identical( got, exp );

  test.case = 'options map';
  var src = { a : 0, e : { d : 'something' } };
  var got = _.entity.search({ src, ins : 'something' });
  var exp = { '/e/d' : 'something' };
  test.identical( got, exp );

  test.case = 'returning : src';
  var src = { a : 0, e : { d : 'something' } };
  var got = _.entity.search({ src, ins : 'something', returning : 'src' });
  var exp = { '/e/d' : 'something' };
  test.identical( got, exp );

}

//

function entitySearchReturningSrc( test )
{

  test.case = 'trivial';
  var src = { a : 0, e : { d : 'something' } };
  var exp = { '/e/d' : 'something' };
  var got = _.entity.search({ src, ins : 'something', returning : 'src' });
  test.contains( got, exp );

}

//

function entitySearchReturningIt( test )
{

  test.case = 'trivial';
  var src = { a : 0, e : { d : 'something' } };
  var got = _.entity.search({ src, ins : 'something', returning : 'it' });
  test.identical( got[ 0 ].path, '/e/d' );

  var exp =
  {
    'childrenCounter' : 0,
    'level' : 2,
    'path' : '/e/d',
    'key' : 'd',
    'cardinal' : 0,
    'index' : 0,
    'src' : 'something',
    'continue' : true,
    'ascending' : false,
    'revisited' : false,
    '_' : null,
    'visiting' : true,
    'iterable' : 0,
    'visitCounting' : true,
    'added' : true
  }
  test.contains( got[ 0 ], exp );
  test.identical( got[ 0 ].childrenCounter, exp.childrenCounter );

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
  var found = _.entity.search
  ({
    src : structure,
    ins : 'str',
    pathJoin,
  });
  var exp =
  {
    '/String::str' : 'str',
    '/Map.polluted::map/String::m3' : 'str',
    '/HashMap::hash/String::m3' : 'str',
  }
  test.identical( found, exp );

  /* - */

  function clean()
  {
    ups.splice( 0, ups.length );
    dws.splice( 0, dws.length );
  }

  // function pathJoin( /* selectorPath, upToken, defaultUpToken, selectorName */ )
  function pathJoin( selectorPath, selectorName )
  {
    // let selectorPath = arguments[ 0 ];
    // let upToken = arguments[ 1 ];
    // let defaultUpToken = arguments[ 2 ];
    // let selectorName = arguments[ 3 ];

    let it = this;
    let result;

    _.assert( arguments.length === 2 );

    selectorPath = _.strRemoveEnd( selectorPath, it.upToken );

    // if( _.strEnds( selectorPath, upToken ) )
    // {
    //   result = selectorPath + _.entity.strType( it.src ) + '::' + selectorName;
    // }
    // else
    // {
    //   result = selectorPath + defaultUpToken + _.entity.strType( it.src ) + '::' + selectorName;
    // }

    result = selectorPath + it.defaultUpToken + _.entity.strType( it.src ) + '::' + selectorName;

    return result;
  }

}

//

function entitySearchMapFromObjectLoop( test )
{
  let ups = [];
  let dws = [];
  let structure =
  {
    a : 1,
    obj1 : new Obj({ b : 2 }),
  }
  structure.obj1.itself = structure.obj1;

  /* - */

  test.case = 'basic';
  clean();
  var found = _.entity.search
  ({
    src : structure,
    ins : 2,
    onUp,
    onDown,
    iterableEval,
  });
  var exp =
  {
    '/obj1/b' : 2,
  }
  test.identical( found, exp );

  var exp = [ '/', '/a', '/obj1', '/obj1/b', '/obj1/itself' ];
  test.identical( ups, exp );
  var exp = [ '/a', '/obj1/b', '/obj1/itself', '/obj1', '/' ];
  test.identical( dws, exp );

  /* - */

  function Obj( src )
  {
    return _.props.extend( this, src );
  }

  function clean()
  {
    ups.splice( 0, ups.length );
    dws.splice( 0, dws.length );
  }

  function iterableEval()
  {
    let it = this;
    if( _.object.isBasic( it.src ) )
    it.iterable = 'Node';
    else
    it.Seeker.iterableEval.call( it );
  }

  function onUp( e, k, _it )
  {
    let it = this;

    _.assert( arguments.length === 3 );
    ups.push( it.path );

    // it.onAscend = function nodeAscend()
    it.ascend = function nodeAscend()
    {
      let node = this.src;
      if( !_.object.isBasic( node ) )
      return;
      let map = _.props.extend( null, node );
      return this._auxAscend( map );
    }

  }

  function onDown( e, k, _it )
  {
    let it = this;

    _.assert( arguments.length === 3 );
    dws.push( it.path );

  }

}

//

function entitySearchMapTopToBottom( test )
{
  let ups = [];
  let dws = [];
  let structure =
  {
    el1 :
    {
      elements :
      [
        { el1 : { code : 'test' }, el2 : { code : '.' }, el3 : { code : 'setsAreIdentical' }, code : 'test.setsAreIdentical' },
        { code : '( rel( _.props.keys( map ) ), [] )' },
      ],
      code : 'test.setsAreIdentical( rel( _.props.keys( map ) ), [] )',
    },
    el2 : { code : ';' },
    code : 'test.setsAreIdentical( rel( _.props.keys( map ) ), [] );test.setsAreIdentical = null;',
    el3 :
    {
      code : 'test.setsAreIdentical = null;',
    }
  }

  /* - */

  test.case = 'basic';
  clean();
  var found = _.entity.search
  ({
    src : structure,
    ins : 'st.setsAreIdent',
    order : 'top-to-bottom',
    onUp,
    onDown,
  });
  var exp =
  {
    '/el1/elements/#0/code' : 'test.setsAreIdentical',
    '/el1/code' : 'test.setsAreIdentical( rel( _.props.keys( map ) ), [] )',
    '/code' : 'test.setsAreIdentical( rel( _.props.keys( map ) ), [] );test.setsAreIdentical = null;',
    '/el3/code' : 'test.setsAreIdentical = null;'
  }
  test.identical( found, exp );

  var exp =
  [
    '/',
    '/el1',
    '/el1/elements',
    '/el1/elements/#0',
    '/el1/elements/#0/el1',
    '/el1/elements/#0/el1/code',
    '/el1/elements/#0/el2',
    '/el1/elements/#0/el2/code',
    '/el1/elements/#0/el3',
    '/el1/elements/#0/el3/code',
    '/el1/elements/#0/code',
    '/el1/elements/#1',
    '/el1/elements/#1/code',
    '/el1/code',
    '/el2',
    '/el2/code',
    '/code',
    '/el3',
    '/el3/code'
  ]
  test.identical( ups, exp );
  var exp =
  [
    '/el1/elements/#0/el1/code',
    '/el1/elements/#0/el1',
    '/el1/elements/#0/el2/code',
    '/el1/elements/#0/el2',
    '/el1/elements/#0/el3/code',
    '/el1/elements/#0/el3',
    '/el1/elements/#0/code',
    '/el1/elements/#0',
    '/el1/elements/#1/code',
    '/el1/elements/#1',
    '/el1/elements',
    '/el1/code',
    '/el1',
    '/el2/code',
    '/el2',
    '/code',
    '/el3/code',
    '/el3',
    '/'
  ]
  test.identical( dws, exp );

  /* - */

  function clean()
  {
    ups.splice( 0, ups.length );
    dws.splice( 0, dws.length );
  }

  function onUp( e, k, _it )
  {
    let it = this;
    ups.push( it.path );
  }

  function onDown( e, k, _it )
  {
    let it = this;
    dws.push( it.path );
  }

}

entitySearchMapTopToBottom.description =
`
- top to down order adds leafs first, then branches, then the root
`

//

function entitySearchMapTopToBottomWithOnUp( test )
{
  let ups = [];
  let dws = [];
  let structure =
  {
    el1 :
    {
      notCode1 : 'test.setsAreIdentical',
      elements :
      [
        { el1 : { code : 'test' }, el2 : { code : '.' }, el3 : { code : 'setsAreIdentical' }, code : 'test.setsAreIdentical' },
        { code : '( rel( _.props.keys( map ) ), [] )' },
      ],
      notCode2 : 'test.setsAreIdentical',
      code : 'test.setsAreIdentical( rel( _.props.keys( map ) ), [] )',
    },
    el2 : { code : ';' },
    el3 :
    {
      code : 'test.setsAreIdentical = null;',
    },
    code : 'test.setsAreIdentical( rel( _.props.keys( map ) ), [] );test.setsAreIdentical = null;',
  }

  /* - */

  test.case = 'basic';
  clean();
  var found = _.entity.search
  ({
    src : structure,
    ins : 'st.setsAreIdent',
    order : 'top-to-bottom',
    onUp,
    onDown,
  });
  var exp =
  {
    '/el1/notCode1' : 'test.setsAreIdentical',
    '/el1/elements/#0/code' : 'test.setsAreIdentical',
    '/el1/notCode2' : 'test.setsAreIdentical',
    '/el3/code' : 'test.setsAreIdentical = null;'
  }
  test.identical( found, exp );

  var exp =
  [
    '/',
    '/el1',
    '/el1/notCode1',
    '/el1/elements',
    '/el1/elements/#0',
    '/el1/elements/#0/el1',
    '/el1/elements/#0/el1/code',
    '/el1/elements/#0/el2',
    '/el1/elements/#0/el2/code',
    '/el1/elements/#0/el3',
    '/el1/elements/#0/el3/code',
    '/el1/elements/#0/code',
    '/el1/elements/#1',
    '/el1/elements/#1/code',
    '/el1/notCode2',
    '/el1/code',
    '/el2',
    '/el2/code',
    '/el3',
    '/el3/code',
    '/code'
  ]
  test.identical( ups, exp );
  var exp =
  [
    '/el1/notCode1',
    '/el1/elements/#0/el1/code',
    '/el1/elements/#0/el1',
    '/el1/elements/#0/el2/code',
    '/el1/elements/#0/el2',
    '/el1/elements/#0/el3/code',
    '/el1/elements/#0/el3',
    '/el1/elements/#0/code',
    '/el1/elements/#0',
    '/el1/elements/#1/code',
    '/el1/elements/#1',
    '/el1/elements',
    '/el1/notCode2',
    '/el1/code',
    '/el1',
    '/el2/code',
    '/el2',
    '/el3/code',
    '/el3',
    '/code',
    '/'
  ]
  test.identical( dws, exp );

  /* - */

  function clean()
  {
    ups.splice( 0, ups.length );
    dws.splice( 0, dws.length );
  }

  function onUp( e, k, _it )
  {
    let it = this;
    ups.push( it.path );
    if( k === 'code' )
    if( it.down.added )
    it.continue = false;
  }

  function onDown( e, k, _it )
  {
    let it = this;
    dws.push( it.path );
  }

}

entitySearchMapTopToBottomWithOnUp.description =
`
- top to down order adds leafs first, then branches, then the root
- if descendant was added then ascendant's code field is ignored
- could not work if field code goes not the last
`

//

function entitySearchMapTopToBottomWithOnAscend( test )
{
  let ups = [];
  let dws = [];
  let structure =
  {
    code : 'test.setsAreIdentical( rel( _.props.keys( map ) ), [] );test.setsAreIdentical = null;',
    el1 :
    {
      notCode1 : 'test.setsAreIdentical',
      code : 'test.setsAreIdentical( rel( _.props.keys( map ) ), [] )',
      elements :
      [
        {
          code : 'test.setsAreIdentical',
          el1 : { code : 'test' },
          el2 : { code : '.' },
          el3 : { code : 'setsAreIdentical' },
        },
        { code : '( rel( _.props.keys( map ) ), [] )' },
      ],
      notCode2 : 'test.setsAreIdentical',
    },
    el2 : { code : ';' },
    el3 :
    {
      code : 'test.setsAreIdentical = null;',
    },
  }

  /* - */

  test.case = 'basic';
  clean();
  var found = _.entity.search
  ({
    src : structure,
    ins : 'st.setsAreIdent',
    order : 'top-to-bottom',
    onUp,
    onDown,
    ascend,
    // onAscend,
  });
  var exp =
  {
    '/el1/notCode1' : 'test.setsAreIdentical',
    '/el1/elements/#0/code' : 'test.setsAreIdentical',
    '/el1/notCode2' : 'test.setsAreIdentical',
    '/el3/code' : 'test.setsAreIdentical = null;'
  }
  test.identical( found, exp );

  var exp =
  [
    '/',
    '/el1',
    '/el1/notCode1',
    '/el1/elements',
    '/el1/elements/#0',
    '/el1/elements/#0/el1',
    '/el1/elements/#0/el1/code',
    '/el1/elements/#0/el2',
    '/el1/elements/#0/el2/code',
    '/el1/elements/#0/el3',
    '/el1/elements/#0/el3/code',
    '/el1/elements/#0/code',
    '/el1/elements/#1',
    '/el1/elements/#1/code',
    '/el1/notCode2',
    '/el1/code',
    '/el2',
    '/el2/code',
    '/el3',
    '/el3/code',
    '/code'
  ]
  test.identical( ups, exp );
  var exp =
  [
    '/el1/notCode1',
    '/el1/elements/#0/el1/code',
    '/el1/elements/#0/el1',
    '/el1/elements/#0/el2/code',
    '/el1/elements/#0/el2',
    '/el1/elements/#0/el3/code',
    '/el1/elements/#0/el3',
    '/el1/elements/#0/code',
    '/el1/elements/#0',
    '/el1/elements/#1/code',
    '/el1/elements/#1',
    '/el1/elements',
    '/el1/notCode2',
    '/el1/code',
    '/el1',
    '/el2/code',
    '/el2',
    '/el3/code',
    '/el3',
    '/code',
    '/'
  ]
  test.identical( dws, exp );

  /* - */

  function clean()
  {
    ups.splice( 0, ups.length );
    dws.splice( 0, dws.length );
  }

  function onUp( e, k, _it )
  {
    let it = this;
    ups.push( it.path );
    if( k === 'code' )
    if( it.down.added )
    it.continue = false;
  }

  function onDown( e, k, _it )
  {
    let it = this;
    dws.push( it.path );
  }

  // function onAscend()
  function ascend()
  {
    let it = this;
    _.assert( arguments.length === 0, 'Expects no arguments' );
    let src = it.src;
    if( _.mapIs( src ) )
    {
      src = _.mapBut_( null, src, { code : null } );
      if( it.src.code !== undefined )
      src.code = it.src.code;
      it.src = src;
    }
    return it.Seeker.ascend.call( it );
    // return it.Seeker.onAscend.call( it );
  }

}

entitySearchMapTopToBottomWithOnAscend.description =
`
- top to down order adds leafs first, then branches, then the root
- if descendant was added then ascendant's code field is ignored
- work even if field code is not the last
`

// --
// from Tools
// --

function entitySize( test )
{

  test.case = 'empty array';
  var src = [];
  test.identical( _.entity.sizeOf( src ), 8 );
  test.identical( _.entity.sizeOf( src, 8 ), 8 );
  test.identical( _.entity.sizeOf( src, 0 ), 0 );

  test.case = 'array';
  var src = [ 3, undefined, 34 ];
  test.identical( _.entity.sizeOf( src ), 32 );
  test.identical( _.entity.sizeOf( src, 8 ), 32 );
  test.identical( _.entity.sizeOf( src, 0 ), 24 );

  test.case = 'argumentsArray';
  var src = _.argumentsArray.make( [ 1, null, 4 ] );
  test.identical( _.entity.sizeOf( src ), 32 );
  test.identical( _.entity.sizeOf( src, 8 ), 32 );
  test.identical( _.entity.sizeOf( src, 0 ), 24 );

  test.case = 'unroll';
  var src = _.unroll.make( [ 1, 2, 'str' ] );
  test.identical( _.entity.sizeOf( src ), 35 );
  test.identical( _.entity.sizeOf( src, 8 ), 35 );
  test.identical( _.entity.sizeOf( src, 0 ), 19 );

  test.case = 'BufferTyped';
  var src = new U8x( [ 1, 2, 3, 4 ] );
  test.identical( _.entity.sizeOf( src ), 12 );
  test.identical( _.entity.sizeOf( src, 8 ), 12 );
  test.identical( _.entity.sizeOf( src, 0 ), 4 );

  test.case = 'BufferRaw';
  var src = new BufferRaw( 10 );
  test.identical( _.entity.sizeOf( src ), 18 );
  test.identical( _.entity.sizeOf( src, 8 ), 18 );
  test.identical( _.entity.sizeOf( src, 0 ), 10 );

  test.case = 'BufferView';
  var src = new BufferView( new BufferRaw( 10 ) );
  test.identical( _.entity.sizeOf( src ), 18 );
  test.identical( _.entity.sizeOf( src, 8 ), 18 );
  test.identical( _.entity.sizeOf( src, 0 ), 10 );

  test.case = 'Set';
  var src = new Set( [ 1, 2, undefined, 4 ] );
  test.identical( _.entity.sizeOf( src ), 40 );
  test.identical( _.entity.sizeOf( src, 8 ), 40 );
  test.identical( _.entity.sizeOf( src, 0 ), 32 );

  test.case = 'map';
  var src = { a : 1, b : 2, c : 'str' };
  test.identical( _.entity.sizeOf( src ), 62 );
  test.identical( _.entity.sizeOf( src, 8 ), 62 );
  test.identical( _.entity.sizeOf( src, 0 ), 46 );

  test.case = 'HashMap';
  var src = new HashMap( [ [ undefined, undefined ], [ 1, 2 ], [ '', 'str' ] ] );
  test.identical( _.entity.sizeOf( src ), 59 );
  test.identical( _.entity.sizeOf( src, 8 ), 59 );
  test.identical( _.entity.sizeOf( src, 0 ), 43 );

  test.case = 'pure map';
  var src = Object.create( null );
  var o =
  {
    'property3' :
    {
      enumerable : true,
      value : 'World',
      writable : true
    },
  };
  Object.defineProperties( src, o );
  test.identical( _.entity.sizeOf( src ), 38 );
  test.identical( _.entity.sizeOf( src, 8 ), 38 );
  test.identical( _.entity.sizeOf( src, 0 ), 22 );

}

// --
// declare
// --

const Proto =
{

  name : 'Tools.l4.LookerExtra',
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

    entitySearchMapFromObjectLoop,
    entitySearchMapTopToBottom,
    entitySearchMapTopToBottomWithOnUp,
    entitySearchMapTopToBottomWithOnAscend,

    entitySize,

    // /* qqq : implement test routine iteratorResult, similar replicator have

  }

}

const Self = wTestSuite( Proto );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
