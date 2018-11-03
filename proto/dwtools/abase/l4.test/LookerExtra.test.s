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

  _.include( 'wTesting' );
  _.include( 'wStringer' );
  _.include( 'wStringsExtra' );

}

var _global = _global_;
var _ = _global_.wTools;

// --
// tests
// --

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

  }

}

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
/*_.*/wTester.test( Self.name );

})();
