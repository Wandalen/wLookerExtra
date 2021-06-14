( function _LookerExtra_s_()
{

'use strict';

/**
 * Collection of light-weight routines to traverse complex data structure. LookerExtra extends Looker by extra routines based on the routine look.
  @module Tools/base/LookerExtra
  @extends Tools
*/

if( typeof module !== 'undefined' )
{

  const _ = require( '../../../node_modules/Tools' );

  _.include( 'wLooker' );

}

const _global = _global_;
const _ = _global_.wTools;
const Parent = _.looker.Looker;
_.searcher = _.searcher || Object.create( _.looker );

_.assert( !!Parent );
_.assert( !!_realGlobal_ );

/* qqq : write nice example for readme */

// --
// relations
// --

let Prime =
{

  src : undefined,
  ins : undefined,
  condition : null,

  onUp : null,
  onDown : null,
  onValueForCompare : onValueForCompareOnceDefault,
  onKeyForCompare : onKeyForCompareOnceDefault,

  onlyOwn : 1,
  recursive : Infinity,

  order : 'all',
  returning : 'src',

  searchingKey : 1,
  searchingValue : 1,
  searchingSubstring : 1,
  searchingCaseInsensitive : 0,

}

// --
// each
// --

/**
 * @param {Object} o Options map.
 *
 * @function wrap
 * @namespace Tools
 * @module Tools/base/LookerExtra
 */

/* qqq : refactor to make it similar to search */
function wrap( o )
{
  let result = o.dst;

  _.routine.options_( wrap, o );
  _.assert( arguments.length === 1, 'Expects single argument' );

  if( o.onCondition )
  o.onCondition = _filter_functor( o.onCondition, 1 );

  /* */

  function handleDown( e, k, it )
  {

    if( o.onCondition )
    if( !o.onCondition.call( this, e, k, it ) )
    return

    if( o.onWrap )
    {
      let newElement = o.onWrap.call( this, e, k, it );

      if( newElement !== e )
      {
        if( e === result )
        result = newElement;
        if( it.down && it.down.src )
        it.down.src[ it.key ] = newElement;
      }

    }
    else
    {

      let newElement = { _ : e };
      if( e === result )
      result = newElement;
      else
      it.down.src[ it.key ] = newElement;

    }

  }

  /* */

  _.look
  ({
    src : o.dst,
    onlyOwn : o.own,
    levels : o.levels,
    onDown : handleDown,
  });

  return result;
}

wrap.defaults =
{

  onCondition : null,
  onWrap : null,
  dst : null,
  onlyOwn : 1,
  levels : 256,

}

//

/**
 * @summary Finds all occurences of a value `o.ins` in entity `o.src`.
 *
 * @param {Object} o Options map
 * @param {Object|Array} o.src Source entity
 * @param {*} o.ins Entity to find. It can be a value of element, name of the property or index of the element.
 * @param {*} condition=null
 * @param {Function} onUp=function(){}
 * @param {Function} onDown=function(){}
 * @param {Boolean} own=1
 * @param {Number} recursive=Infinity
 * @param {Boolean} searchingKey=1
 * @param {Boolean} searchingValue=1
 * @param {Boolean} searchingSubstring=1
 * @param {Boolean} searchingCaseInsensitive=0
 *
 * @returns {Object} Returns map with paths to found elements and their values.
 *
 * @example
 * _.search({ a : 1, b : 2, c : 1 }, 1 ); // { '/a : 1', '/c' : 1}
 *
 * @example
 * _.search({ a : 1, b : 2, c : 1 }, 'a' ); // { '/a' : 1 }
 *
 * @example
 * _.search({ a : { b : 1, c : 2 }  }, 2 ) // { '/a/c' : 2}
 *
 * @function search
 * @namespace Tools
 * @module Tools/base/LookerExtra
 */

//

function search_body( it )
{
  _.searcher.Seeker.exec.body( it );
  return it.result;
}

//

function optionsFromArguments( args )
{
  let o = args[ 0 ] || Object.create( null );

  if( args.length === 2 )
  {
    o = { src : args[ 0 ], ins : args[ 1 ] };
  }

  _.assert( args.length === 1 || args.length === 2 );
  _.assert( arguments.length === 1 );
  _.assert( _.mapIs( o ) );

  return o;
}

//

function resultAdd()
{
  let it = this;
  let e = it.src;
  let path = it.path;

  _.assert( arguments.length === 0, 'Expects no arguments' );

  if( it.iterator.returning === 'it' )
  {
    e = it;
  }

  if( it.iterator.returning === 'src' )
  it.result[ path ] = e;
  else
  it.result.push( e );

  it.added = true;
  if( it.order === 'top-to-bottom' )
  it.continue = false;

}

//

function iterationCompareAndAddOnce()
{
  let it = this;
  let e = it.src;
  let k = it.key;

  if( it.iterator.searchingValue )
  {
    let value = it.onValueForCompare( e, k );
    if( it.compare( value, k ) )
    it.resultAdd();
  }

  if( it.iterator.searchingKey )
  {
    if( it.compare( it.onKeyForCompare( e, k ), k ) )
    it.resultAdd();
  }

}

//

function compare( e, k )
{
  let it = this;

  _.assert( arguments.length === 2 );

  if( it.iterator.condition )
  {
    if( !it.iterator.condition.call( this, e, k, it ) )
    return false;
  }

  if( e === it.iterator.ins )
  {
    return true;
  }
  else if( it.insRegexp )
  {
    if( it.insRegexp.test( e ) )
    return true;
  }
  else if( it.iterator.searchingSubstring && _.strIs( e ) && e.indexOf( it.insStr ) !== -1 )
  {
    return true;
  }

  return false;
}

//

function onValueForCompareOnceDefault( e, k )
{
  return e;
}

//

function onKeyForCompareOnceDefault( e, k )
{
  return k;
}

//

function optionsToIteration( iterator, o )
{
  let it = Parent.optionsToIteration.call( this, iterator, o );
  return it;
}

//

function iteratorInitEnd( iterator )
{
  let looker = this;

  _.assert( arguments.length === 1 );
  _.assert( _.longHas( [ 'src', 'it' ], iterator.returning ) );
  _.assert( _.longHas( [ 'all', 'top-to-bottom' ], iterator.order ) );
  _.assert( iterator.onDown === null || iterator.onDown.length === 0 || iterator.onDown.length === 3 );
  _.assert( iterator.onUp === null || iterator.onUp.length === 0 || iterator.onUp.length === 3 );

  if( iterator.returning === 'src' )
  iterator.result = Object.create( null );
  else
  iterator.result = [];

  iterator.insStr = String( iterator.ins );

  if( iterator.searchingCaseInsensitive && _.strIs( iterator.ins ) )
  iterator.insRegexp = new RegExp( ( iterator.searchingSubstring ? '' : '^' ) + iterator.insStr + ( iterator.searchingSubstring ? '' : '$' ), 'i' );

  if( iterator.condition )
  {
    iterator.condition = _filter_functor( iterator.condition, 1 );
    _.assert( iterator.condition.length === 0 || iterator.condition.length === 3 );
  }

  /* */

  _.assert( iterator.onUp2 === null ); /* xxx0 : remove from defaults. write test */
  _.assert( iterator.onDown2 === null );

  iterator.onUp2 = iterator.onUp;
  iterator.onDown2 = iterator.onDown;
  iterator.onUp = iterator._searchUp;
  iterator.onDown = iterator._searchDown;

  /* */

  return Parent.iteratorInitEnd.call( this, iterator );
}

//

function _searchUp( e, k, it )
{

  _.assert( arguments.length === 3 );

  if( it.onUp2 )
  {
    let r = it.onUp2.call( this, e, k, it );
    _.assert( r === undefined );
  }

  if( !it.continue || !it.iterator.continue )
  return;

  if( it.order === 'top-to-bottom' )
  return;

  it.iterationCompareAndAddOnce( it );

}

//

function _searchDown( e, k, it )
{

  _.assert( arguments.length === 3 );

  if( it.onDown2 )
  {
    let r = it.onDown2.call( this, e, k, it );
    _.assert( r === undefined );
  }

  if( !it.continue || !it.iterator.continue )
  return end();

  if( it.order === 'top-to-bottom' )
  if( !it.added )
  it.iterationCompareAndAddOnce( it );

  return end();

  function end()
  {
    if( it.added )
    if( it.down )
    {
      it.down.added = true;
    }
  }
}

//

/**
 * @summary Recursively freezes properties/elements of an entity( src ). Frozen enity can't be changed.
 * @param {*} src Source entity.
 *
 * @example
 * let src = { a : 1 };
 * _.freezeRecursive( src );
 * src.a = 5;
 * console.log( src.a )//1
 *
 * @function freezeRecursive
 * @namespace Tools
 * @module Tools/base/LookerExtra
 */

function freezeRecursive( src )
{
  let lookOptions = Object.create( null );

  lookOptions.src = src;
  lookOptions.onUp = function handleUp( e, k, it )
  {
    _.entityFreeze( e )
  }

  _.look( lookOptions );

  return src;
}

// --
// transformer
// --

/**
 * Groups elements of entities from array( src ) into the object with key( o.key )
 * that contains array of values that corresponds to key( o.key ) from that entities.
 * If function cant find key( o.key ) it replaces key value with undefined.
 *
 * @param { array } [ o.src=null ] - The target array.
 * @param { array|string } [ o.key=null ] - Array of keys to search or one key as string.
 * @param { array|string } [ o.usingOriginal=1 ] - Uses keys from entities to represent elements values.
 * @param { objectLike | string } o - Options.
 * @returns { object } Returns an object with values grouped by key( o.key ).
 *
 * @example
 * // returns
 * //{
 * //  key1 : [ 1, 2, 3 ],
 * //  key3 : [ undefined, undefined, undefined ]
 * //}
 * _.group( { src : [ {key1 : 1, key2 : 2 }, {key1 : 2 }, {key1 : 3 }], usingOriginal : 0, key : ['key1', 'key3']} );
 *
 * @example
 * // returns
 * // {
 * //   a :
 * //   {
 * //     1 : [ { a : 1, b : 2 } ],
 * //     2 : [ { a : 2, b : 3 } ],
 * //     undefined : [ { c : 4 } ]
 * //   }
 * // }
 * _.group( { src : [ { a : 1, b : 2 }, { a : 2, b : 3}, {  c : 4 }  ], key : ['a'] }  );
 *
 * @function group
 * @throws {exception} If( arguments.length ) is not equal 1.
 * @throws {exception} If( o.key ) is not a Array or String.
 * @throws {exception} If( o.src ) is not a Array-like or Object-like.
 * @namespace Tools
 * @module Tools/base/LookerExtra
 */

function group( o )
{
  o = o || Object.create( null );

  /* key */

  if( o.key === undefined || o.key === null )
  {

    if( o.usingOriginal === undefined )
    o.usingOriginal = 0;

    if( _.longIs( o.key ) )
    o.key = _.props.keys.apply( _, o.src );
    else
    o.key = _.props.keys.apply( _, _.props.vals( o.src ) );

  }

  /* */

  o = _.routine.options_( group, o );

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.strIs( o.key ) || _.arrayIs( o.key ) );
  _.assert( _.objectLike( o.src ) || _.longIs( o.src ) );
  _.assert( _.arrayIs( o.src ), 'not tested' );

  /* */

  let result;
  if( _.arrayIs( o.key ) )
  {

    result = Object.create( null );
    for( let k = 0 ; k < o.key.length ; k++ )
    {
      let r = o.usingOriginal ? Object.create( null ) : _.entity.cloneShallow( o.src );
      result[ o.key[ k ] ] = groupForKey( o.key[ k ], r );
    }

  }
  else
  {
    result = Object.create( null );
    groupForKey( o.key, result );
  }

  /**/

  return result;

  /* */

  function groupForKey( key, result )
  {

    _.each( o.src, function( e, k )
    {

      let value = o.usingOriginal ? o.src[ k ] : o.src[ k ][ key ];
      let dstKey = o.usingOriginal ? o.src[ k ][ key ] : k;

      if( o.usingOriginal )
      {
        if( result[ dstKey ] === undefined )
        result[ dstKey ] = [];
        result[ dstKey ].push( value );
      }
      else
      {
        result[ dstKey ] = value;
      }

    });

    return result;
  }

}

group.defaults =
{
  src : null,
  key : null,
  usingOriginal : 1,
}

//

function sizeOf( src, sizeOfContainer )
{
  let result = 0;

  if( arguments.length === 1 )
  sizeOfContainer = 8;

  _.assert( _.number.defined( sizeOfContainer ) );
  _.assert( arguments.length === 1 || arguments.length === 2 );

  // if( _.primitive.is( src ) || !_.iterableIs( src ) || _.bufferAnyIs( src ) ) /* yyy */
  // if( _.primitive.is( src ) || _.bufferAnyIs( src ) ) /* Dmytro : added branch for routine iterableIs, routine countableIs has different behavior */
  // if( _.primitive.is( src ) || _.bufferAnyIs( src ) || !( _.mapIs( src ) || _.class.methodIteratorOf( src ) ) )
  if( _.primitive.is( src ) || _.bufferAnyIs( src ) || _.routineIs( src ) || _.regexpIs( src ) )
  return _.entity.sizeOfUncountable( src, sizeOfContainer );

  if( _.look )
  // if( _.containerIs( src ) || _.iterableIs( src ) ) /* yyy */
  // if( _.containerIs( src ) )
  // if( _.containerIs( src ) || !( _.mapIs( src ) || _.class.methodIteratorOf( src ) ) )
  {
    _.look({ src, onUp : onEach, withCountable : 1 });
  }

  if( _.look )
  return result;

  return NaN;

  function onEach( e, k, it )
  {

    if( !_.number.defined( result ) )
    {
      it.iterator.continue = false;
      return;
    }

    if( it.iterable !== _.looker.Looker.ContainerType.terminal )
    result += sizeOfContainer;

    if( !it.down )
    return;

    // if( it.down.iterable === 'map-like' || it.down.iterable === 'hash-map-like' )
    if( it.down.iterable === _.looker.Looker.ContainerType.aux || it.down.iterable === _.looker.Looker.ContainerType.hashMap )
    result += _.entity.sizeOfUncountable( k );

    // if( _.primitive.is( e ) || !_.iterableIs( e ) || _.bufferAnyIs( e ) ) /* yyy */
    if( _.primitive.is( e ) || _.bufferAnyIs( e ) ) /* yyy */
    result += _.entity.sizeOfUncountable( e, sizeOfContainer );

  }

}

// --
// relations
// --

let Looker =
{

  constructor : function Searcher(){},

  optionsFromArguments,
  optionsToIteration,
  iteratorInitEnd,

  _searchUp,
  _searchDown,
  resultAdd,
  iterationCompareAndAddOnce,
  compare,
  onValueForCompare : onValueForCompareOnceDefault,
  onValueForCompareOnceDefault,
  onKeyForCompare : onKeyForCompareOnceDefault,
  onKeyForCompareOnceDefault,

}

let Iterator =
{

  insStr : null,
  insRegexp : null,

  onUp2 : null,
  onDown2 : null,

}

let Iteration =
{
  added : null,
}

let IterationPreserve =
{
}

let Searcher = _.looker.classDefine
({
  name : 'Searcher',
  prime : Prime,
  seeker : Looker,
  iterator : Iterator,
  iteration : Iteration,
  iterationPreserve : IterationPreserve,
});

_.assert( Searcher.onKeyForCompare === onKeyForCompareOnceDefault );

/* qqq : split lookers by files */

const searchIt = Searcher.exec;

_.assert( searchIt.defaults.order === 'all' );
_.assert( searchIt.defaults === Searcher );

_.assert( searchIt.body.defaults.order === 'all' );
_.assert( searchIt.body.defaults === Searcher );

search_body.defaults = Searcher;

let search = _.routine.uniteCloning_replaceByUnite({ head : searchIt.head, body : search_body, strategy : 'replacing' });

_.assert( searchIt.defaults.order === 'all' );
_.assert( searchIt.defaults === Searcher );

const Self = Searcher;

// --
// declare
// --

let EntityExtension =
{

  // unsorted

  wrap,
  search,
  freezeRecursive,
  group, /* experimental */
  sizeOf,

}

let SearcherExtension =
{

  // ... _.looker,
  // is : _.looker.is,
  // iteratorIs : _.looker.iteratorIs,
  // iterationIs : _.looker.iterationIs,
  // classDefine : _.looker.classDefine,

  searchIt,
  look : searchIt,
  search,
  Seeker : Searcher,
  Searcher,

}

Object.assign( _.entity, EntityExtension );
Object.assign( _.searcher, SearcherExtension );
_.assert( _.routineIs( _.searcher.iteratorIs ) );

// --
// export
// --

if( typeof module !== 'undefined' )
module[ 'exports' ] = _;

})();
