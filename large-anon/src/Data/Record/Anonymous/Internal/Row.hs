{-# LANGUAGE DataKinds             #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies          #-}

-- | Type-level rows
--
-- For each class defined here we additionally define the type of the
-- dictionary for the benefit of "Data.Record.Anonymous.Internal.Evidence".
--
-- NOTE: Apart from 'FieldTypes', none of the definitions in this module take
-- a functor argument (@f@). This is intentional: it makes then more general,
-- and moreover useable in both the advanced and the simple interface.
--
-- Intended for unqualified import.
module Data.Record.Anonymous.Internal.Row (
    -- * Isomorphic records
    Isomorphic
    -- * Merging records
  , Merge
    -- * Constraints
  , AllFields(..)
  , AllFieldsDict
    -- * Metadata
  , KnownFields(..)
  , KnownFieldsDict
  , FieldTypes
  , fieldNames
  ) where

import Data.Kind
import Data.Proxy (Proxy)
import Data.Record.Generic (FieldMetadata(..))
import Data.SOP.Dict
import Data.Vector (Vector)
import GHC.Exts (Any)
import GHC.TypeLits

{-------------------------------------------------------------------------------
  Isomorphic records
-------------------------------------------------------------------------------}

-- | Row isomorphism
--
-- Instances of this class are provided by the plugin.
--
-- See 'castRecord' for details.
class Isomorphic (xs :: [(Symbol, Type)]) (ys :: [(Symbol, Type)]) where

{-------------------------------------------------------------------------------
  Merging records
-------------------------------------------------------------------------------}

-- | Merge two records
--
-- The 'Merge' type family does not reduce: the following two types are /not/
-- considered to be equal:
--
-- > Record '[ '("a", Bool) ']
-- > Record (Merge '[ '("a", Bool) '] '[])
--
-- They are /isomorphic/ (see 'castRecord'), but not /equal/.
--
-- As a consequence, the 'Merge' type family is injective: if
--
-- > Merge xs ys ~ Merge xs' ys'
--
-- then @xs ~ xs'@ and @ys ~ ys'@. Example:
--
-- >>> :{
--   let foo :: Merge '[ '("a", Bool) ] '[] ~ Merge '[] '[ '("a", Bool) ] => ()
--       foo = ()
--   in foo
-- :}
-- ...
-- ...Couldn't match...[]...
-- ...
--
-- See 'merge' for additional information.
type family Merge :: [(Symbol, Type)] -> [(Symbol, Type)] -> [(Symbol, Type)]

{-------------------------------------------------------------------------------
  Constraints
-------------------------------------------------------------------------------}

-- | Dictionary for @c x@ for each field of type @x@ in the row
--
-- Instances of this class are provided by the plugin.
class AllFields (r :: [(Symbol, Type)]) (c :: Type -> Constraint) where
  -- | Vector of dictionaries, in row order
  --
  -- This is a low-level function that should not be used in user code.
  -- Use 'constrain' or one of the constrained combinators such as 'cmap'.
  fieldDicts :: AllFieldsDict r c

type AllFieldsDict (r :: [(Symbol, Type)]) (c :: Type -> Constraint) =
       Proxy r -> Proxy c -> Vector (Dict c Any)

{-------------------------------------------------------------------------------
  Metadata
-------------------------------------------------------------------------------}

class KnownFields (r :: [(Symbol, Type)]) where
  -- | Metadata for each field, in row order
  --
  -- This is a low-level function that should not be used in user code.
  fieldMetadata :: KnownFieldsDict r

type KnownFieldsDict (r :: [(Symbol, Type)]) =
       Proxy r -> [FieldMetadata Any]

-- | Names of all fields, in row order
fieldNames :: KnownFields r => Proxy r -> [String]
fieldNames = map aux . fieldMetadata
  where
    aux :: FieldMetadata Any -> String
    aux (FieldMetadata p _strictness) = symbolVal p

type family FieldTypes (f :: Type -> Type) (r :: [(Symbol, Type)]) :: [(Symbol, Type)]
  -- Rewritten by the plugin
