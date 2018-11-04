( function _LookerExtra_test_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  if( typeof _global_ === 'undefined' || !_global_.wBase )
  {
    let toolsPath = '../../../dwtools/Base.s';
    let toolsExternal = 0;
    try
    {
      toolsPath = require.resolve( toolsPath );
    }
    catch( err )
    {
      toolsExternal = 1;
      require( 'wTools' );
    }
    if( !toolsExternal )
    require( toolsPath );
  }

  var _ = _global_.wTools;

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

  var src = { a : 0, e : { d : 'something' } };
  var got = _.entitySearch( src, 'something' );
  var expected = { '/e/d' : 'something' };

  test.identical( got, expected );

}

// --
// declare
// --

var Self =
{

  name : 'Tools/base/l4/LookerExtra',
  silencing : 1,
  enabled : 1,

  context :
  {
  },

  tests :
  {

    entitySearch : entitySearch,

  }

}

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
/*_.*/wTester.test( Self.name );

})();
