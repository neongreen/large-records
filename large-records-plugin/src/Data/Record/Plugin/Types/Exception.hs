{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE LambdaCase #-}

-- Exceptions that may be thrown by the large-records plugin.
module Data.Record.Plugin.Types.Exception
  ( Exception (..),
    formatException,
  )
where

import Data.Record.Plugin.GHC
import Data.Set (Set)
import qualified Data.Set as Set

data Exception
  = DerivingWithoutStrategy
  | UnsupportedStockDeriving (HsType GhcPs)
  | UnsupportedStrategy (DerivStrategy GhcPs)
  | InvalidDeclaration
  | Untransformed (Set RdrName)

-- TODO: better exception messages
formatException :: DynFlags -> Exception -> String
formatException dynFlags = \case
  DerivingWithoutStrategy ->
    "Only derivings with explicit strategy are supported"
  UnsupportedStockDeriving ty ->
    "Unsupported stock class: " ++ showSDoc dynFlags (ppr ty)
  UnsupportedStrategy strategy ->
    "Strategy " ++ showSDoc dynFlags (derivStrategyName strategy) ++ " is not supported"
  InvalidDeclaration ->
    "Unsupported declaration for large-records"
  Untransformed names ->
    unlines do
      "These large-record annotations were not applied: " : do
        name <- Set.toList names
        pure (" - " ++ rdrNameString name)
