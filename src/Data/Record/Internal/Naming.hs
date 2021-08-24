{-# LANGUAGE DataKinds       #-}
{-# LANGUAGE RecordWildCards #-}

-- | Names of the various things we generate
--
-- This is used by both TH code generation and the quasi-quoter.
module Data.Record.Internal.Naming (
    -- * Names based on the constructor
    nameRecordInternalConstr
    -- * Names based on the type
  , nameRecordConstraintsClass
  , nameRecordConstraintsMethod
  , nameRecordIndexedAccessor
  , nameRecordIndexedOverwrite
  , nameRecordInternalField
  , nameRecordView
  ) where

import Data.Record.TH.Config.Options (GenPatSynonym(..))

{-------------------------------------------------------------------------------
  Names based on the constructor
-------------------------------------------------------------------------------}

-- | The name of the constructor used internally
--
-- We pick a different name depending on whether or not we generate a
-- pattern synonym.
--
-- o We if /do/ generate a pattern synonym, we must pick the internal name of
--   constructor to be different from the name of the pattern synonym
--   constructor.
--
-- o We if do /not/ generate a pattern synonym and rely on the quasi-quoter
--   instead, we instead use the constructor name as the user wrote it.
--
-- This has two consequences:
--
-- o Users can always export @R(MkR)@ from their modules: if the pattern synonym
--   is exported, this exports the type and the synonym; if the pattern synonym
--   is not exported, this exports the type and the internal constructor (which
--   is important, because although user-written code will not use that
--   internal constructor directly, code generated by the quasi-quoter will).
--
-- o If the quasi-quoter is used but the pattern synonym /is/ generated, the
--   quasi-quoter will end up trying to ask ghc for information about the wrong
--   thing (it will try to ask for information about the constructor, but will
--   inadvertently end up asking for information about the pattern synonym).
--   This means that the quasi-quoter cannot be used when the pattern synonym
--   is generated.
nameRecordInternalConstr :: GenPatSynonym -> String -> String
nameRecordInternalConstr GenPatSynonym  = ("LR__" ++)
nameRecordInternalConstr UseQuasiQuoter = id

{-------------------------------------------------------------------------------
  Names based on the type
-------------------------------------------------------------------------------}

nameRecordConstraintsClass  :: String -> String
nameRecordConstraintsMethod :: String -> String
nameRecordIndexedAccessor   :: String -> String
nameRecordIndexedOverwrite  :: String -> String
nameRecordInternalField     :: String -> String
nameRecordView              :: String -> String

nameRecordConstraintsClass  = ("Constraints_"     ++)
nameRecordConstraintsMethod = ("dictConstraints_" ++)
nameRecordIndexedAccessor   = ("unsafeGetIndex"   ++)
nameRecordIndexedOverwrite  = ("unsafeSetIndex"   ++)
nameRecordInternalField     = ("vectorFrom"       ++)
nameRecordView              = ("tupleFrom"        ++)
