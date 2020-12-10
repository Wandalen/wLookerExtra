( function _LookerExtra_s_() {

'use strict';

/**
 * Collection of light-weight routines to traverse complex data structure. LookerExtra extends Looker by extra routines based on the routine look.
  @module Tools/base/LookerExtra
  @extends Tools
*/

/**
 *  */

/**
 * Collection of light-weight routines to traverse complex data structure.
*/

if( typeof module !== 'undefined' )
{

  let _ = require( '../../../wtools/Tools.s' );

  _.include( 'wLooker' );

}

let _global = _global_;
let Self = _global_.wTools;
let _ = _global_.wTools;

let _ArraySlice = Array.prototype.slice;
let _FunctionBind = Function.prototype.bind;
let _ObjectToString = Object.prototype.toString;
let _ObjectHasOwnProperty = Object.hasOwnProperty;

_.assert( !!_realGlobal_ );

// --
// each
// --

/**
 * @param {Object} o Options map.
 *
 * @function entityWrap
 * @namespace Tools
 * @module Tools/base/LookerExtra
 */

function entityWrap( o )
{
  let result = o.dst;

  debugger;

  _.routineOptions( entityWrap, o );
  _.assert( arguments.length === 1, 'Expects single argument' );

  if( o.onCondition )
  o.onCondition = _filter_functor( o.onCondition, 1 );

  /* */

  function handleDown( e, k, it )
  {

    debugger;

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

entityWrap.defaults =
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
 * _.entitySearch({ a : 1, b : 2, c : 1 }, 1 ); // { '/a : 1', '/c' : 1}
 *
 * @example
 * _.entitySearch({ a : 1, b : 2, c : 1 }, 'a' ); // { '/a' : 1 }
 *
 * @example
 * _.entitySearch({ a : { b : 1, c : 2 }  }, 2 ) // { '/a/c' : 2}
 *
 * @function entitySearch
 * @namespace Tools
 * @module Tools/base/LookerExtra
 */

function entitySearch( o )
{
  let result;

  if( arguments.length === 2 )
  {
    o = { src : arguments[ 0 ], ins : arguments[ 1 ] };
  }

  _.mapSupplement( o, entitySearch.defaults );
  _.routineOptions( entitySearch, o );
  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.assert( _.longHas( [ 'src', 'it' ], o.returning ) );
  _.assert( _.longHas( [ 'all', 'top-to-bottom' ], o.order ) );
  // _.assert( _.longHas( [ 'once', 'serial' ], o.comparing ) );

  // if( o.onValueForCompare === null )
  // o.onValueForCompare = o.comparing === 'once' ? onValueForCompareOnceDefault : onValueForCompareSerialDefault;
  // if( o.onKeyForCompare === null )
  // o.onKeyForCompare = o.comparing === 'once' ? onKeyForCompareOnceDefault : onKeyForCompareSerialDefault;

  if( o.onValueForCompare === null )
  o.onValueForCompare = onValueForCompareOnceDefault;
  if( o.onKeyForCompare === null )
  o.onKeyForCompare = onKeyForCompareOnceDefault;

  _.assert( o.onDown === null || o.onDown.length === 0 || o.onDown.length === 3 );
  _.assert( o.onUp === null || o.onUp.length === 0 || o.onUp.length === 3 );

  let iterationCompareAndAdd;
  // if( o.comparing === 'once' )
  iterationCompareAndAdd = iterationCompareAndAddOnce;
  // else
  // iterationCompareAndAdd = iterationCompareAndAddSerial;

  if( o.returning === 'src' )
  result = Object.create( null );
  else
  result = [];

  let strIns, regexpIns;
  strIns = String( o.ins );

  if( o.searchingCaseInsensitive && _.strIs( o.ins ) )
  regexpIns = new RegExp( ( o.searchingSubstring ? '' : '^' ) + strIns + ( o.searchingSubstring ? '' : '$' ), 'i' );

  if( o.condition )
  {
    o.condition = _filter_functor( o.condition, 1 );
    _.assert( o.condition.length === 0 || o.condition.length === 3 );
  }

  /* */

  let onUp = o.onUp;
  let onDown = o.onDown;
  let lookOptions = _.mapOnly( o, _.look.defaults )
  lookOptions.onUp = handleUp;
  lookOptions.onDown = handleDown;
  lookOptions.iteratorExtension = lookOptions.iteratorExtension || Object.create( null );
  lookOptions.iteratorExtension.onValueForCompare = o.onValueForCompare;
  lookOptions.iteratorExtension.onKeyForCompare = o.onKeyForCompare;
  lookOptions.iteratorExtension.order = o.order;
  lookOptions.iteratorExtension.comparing = o.comparing;
  lookOptions.iterationExtension = lookOptions.iterationExtension || Object.create( null );
  lookOptions.iterationExtension.added = null;

  _.look( lookOptions );

  return result;

  /* */

  function handleUp( e, k, it )
  {

    _.assert( arguments.length === 3 );

    if( onUp )
    {
      let r = onUp.call( this, e, k, it );
      _.assert( r === undefined );
    }

    if( !it.continue || !it.iterator.continue )
    return;

    if( it.order === 'top-to-bottom' )
    return;

    iterationCompareAndAdd.call( it );

  }

  /* */

  function handleDown( e, k, it )
  {

    _.assert( arguments.length === 3 );

    if( onDown )
    {
      let r = onDown.call( this, e, k, it );
      _.assert( r === undefined );
    }

    if( !it.continue || !it.iterator.continue )
    return end();

    if( it.order === 'top-to-bottom' )
    if( !it.added )
    iterationCompareAndAdd.call( it );

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

  /* */

  function resultAdd()
  {
    let it = this;
    let e = it.src;
    let path = it.path;

    _.assert( arguments.length === 0, 'Expects no arguments' );

    if( o.returning === 'it' )
    {
      e = it;
    }

    if( o.returning === 'src' )
    result[ path ] = e;
    else
    result.push( e );

    it.added = true;
    if( it.order === 'top-to-bottom' )
    it.continue = false;

  }

  /* */

  function iterationCompareAndAddOnce()
  {
    let it = this;
    let e = it.src;
    let k = it.key;

    // if( _.strHas( it.path, 'comment' ) || _.strHas( it.path, 'Comment' ) )
    // debugger;

    if( o.searchingValue )
    {
      let value = it.onValueForCompare( e, k );
      if( compare.call( this, value, k ) )
      resultAdd.call( this );
    }

    if( o.searchingKey )
    {
      if( compare.call( this, it.onKeyForCompare( e, k ), k ) )
      resultAdd.call( this );
    }

  }

  // /* */
  //
  // function iterationCompareAndAddSerial()
  // {
  //   let it = this;
  //   let e = it.src;
  //   let k = it.key;
  //
  //   if( o.searchingValue )
  //   {
  //     let counter = 0;
  //     let value = it.onValueForCompare( e, k, counter );
  //     while( value !== undefined )
  //     {
  //       if( compare.call( this, value, k ) )
  //       resultAdd.call( this );
  //       else
  //       value = it.onValueForCompare( e, k, counter );
  //     }
  //   }
  //
  //   if( o.searchingKey )
  //   {
  //     let counter = 0;
  //     let value = it.onKeyForCompare( e, k, counter );
  //     while( value !== undefined )
  //     {
  //       if( compare.call( this, value, k ) )
  //       resultAdd.call( this );
  //       else
  //       value = it.onKeyForCompare( e, k, counter );
  //     }
  //   }
  //
  // }

  /* */

  function compare( e, k )
  {

    _.assert( arguments.length === 2 );

    if( o.condition )
    {
      if( !o.condition.call( this, e, k, it ) )
      return false;
    }

    if( e === o.ins )
    {
      return true;
    }
    else if( regexpIns )
    {
      if( regexpIns.test( e ) )
      return true;
    }
    else if( o.searchingSubstring && _.strIs( e ) && e.indexOf( strIns ) !== -1 )
    {
      return true;
    }

    return false;
  }

  /* */

  function onValueForCompareOnceDefault( e, k )
  {
    return e;
  }

  /* */

  function onKeyForCompareOnceDefault( e, k )
  {
    return k;
  }

  /* */

  // function onValueForCompareSerialDefault( e, k, counter )
  // {
  //   if( !counter )
  //   return e;
  // }
  //
  // /* */
  //
  // function onKeyForCompareSerialDefault( e, k )
  // {
  //   if( !counter )
  //   return k;
  // }

  /* */

}

entitySearch.defaults =
{

  src : null,
  ins : null,
  condition : null,

  // onUp : function(){},
  // onDown : function(){},
  onUp : null,
  onDown : null,
  onValueForCompare : null,
  onKeyForCompare : null,

  onlyOwn : 1,
  recursive : Infinity,

  order : 'all',
  // comparing : 'once',
  returning : 'src',
  // usingExactPath : 0,

  searchingKey : 1,
  searchingValue : 1,
  searchingSubstring : 1,
  searchingCaseInsensitive : 0,

}

entitySearch.defaults.__proto__ = _.look.defaults;

//

/**
 * @summary Recursively freezes properties/elements of an entity( src ). Frozen enity can't be changed.
 * @param {*} src Source entity.
 *
 * @example
 * let src = { a : 1 };
 * _.entityFreezeRecursive( src );
 * src.a = 5;
 * console.log( src.a )//1
 *
 * @function entityFreezeRecursive
 * @namespace Tools
 * @module Tools/base/LookerExtra
 */

function entityFreezeRecursive( src )
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

//

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
   * _.entityGroup( { src : [ {key1 : 1, key2 : 2 }, {key1 : 2 }, {key1 : 3 }], usingOriginal : 0, key : ['key1', 'key3']} );
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
   * _.entityGroup( { src : [ { a : 1, b : 2 }, { a : 2, b : 3}, {  c : 4 }  ], key : ['a'] }  );
   *
   * @function entityGroup
   * @throws {exception} If( arguments.length ) is not equal 1.
   * @throws {exception} If( o.key ) is not a Array or String.
   * @throws {exception} If( o.src ) is not a Array-like or Object-like.
   * @namespace Tools
 * @module Tools/base/LookerExtra
   */

function entityGroup( o )
{
  o = o || Object.create( null );

  /* key */

  if( o.key === undefined || o.key === null )
  {

    if( o.usingOriginal === undefined )
    o.usingOriginal = 0;

    if( _.longIs( o.key ) )
    o.key = _.mapKeys.apply( _, o.src );
    else
    o.key = _.mapKeys.apply( _, _.mapVals( o.src ) );

  }

  /* */

  o = _.routineOptions( entityGroup, o );

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
      debugger;
      let r = o.usingOriginal ? Object.create( null ) : _.entityMakeConstructing( o.src );
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

entityGroup.defaults =
{
  src : null,
  key : null,
  usingOriginal : 1,
}

// --
// declare
// --

let Proto =
{

  // unsorted

  entityWrap,
  entitySearch,
  entityFreezeRecursive,
  entityGroup, /* experimental */

}

_.mapSupplement( Self, Proto );

// --
// export
// --

if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

})();
