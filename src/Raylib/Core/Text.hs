{-# OPTIONS -Wall #-}

module Raylib.Core.Text where

import Foreign
  ( Storable (peek, sizeOf),
    toBool,
  )
import Foreign.C
  ( CUChar,
    peekCString,
    withCString,
  )
import Raylib.ForeignUtil
  ( pop,
    popCArray,
    popCString,
    withFreeable,
    withFreeableArray,
    withFreeableArray2D,
    withFreeableArrayLen,
  )
import Raylib.Internal (WindowResources, addTextureId, unloadSingleTexture)
import Raylib.Native
  ( c'codepointToUTF8,
    c'drawFPS,
    c'drawText,
    c'drawTextCodepoint,
    c'drawTextCodepoints,
    c'drawTextEx,
    c'drawTextPro,
    c'exportFontAsCode,
    c'genImageFontAtlas,
    c'getCodepointCount,
    c'getCodepointNext,
    c'getCodepointPrevious,
    c'getFontDefault,
    c'getGlyphAtlasRec,
    c'getGlyphIndex,
    c'getGlyphInfo,
    c'isFontReady,
    c'loadCodepoints,
    c'loadFont,
    c'loadFontData,
    c'loadFontEx,
    c'loadFontFromImage,
    c'loadFontFromMemory,
    c'loadUTF8,
    c'measureText,
    c'measureTextEx,
    c'setTextLineSpacing,
  )
import Raylib.Types
  ( Color,
    Font (font'texture),
    FontType,
    GlyphInfo,
    Image,
    Rectangle,
    Texture (texture'id),
    Vector2,
  )

getFontDefault :: IO Font
getFontDefault = c'getFontDefault >>= pop

loadFont :: String -> WindowResources -> IO Font
loadFont fileName wr = do
  font <- withCString fileName c'loadFont >>= pop
  addTextureId (texture'id $ font'texture font) wr
  return font

loadFontEx :: String -> Int -> [Int] -> Int -> WindowResources -> IO Font
loadFontEx fileName fontSize fontChars glyphCount wr = do
  font <- withCString fileName (\f -> withFreeableArray (map fromIntegral fontChars) (\c -> c'loadFontEx f (fromIntegral fontSize) c (fromIntegral glyphCount))) >>= pop
  addTextureId (texture'id $ font'texture font) wr
  return font

loadFontFromImage :: Image -> Color -> Int -> WindowResources -> IO Font
loadFontFromImage image key firstChar wr = do
  font <- withFreeable image (\i -> withFreeable key (\k -> c'loadFontFromImage i k (fromIntegral firstChar))) >>= pop
  addTextureId (texture'id $ font'texture font) wr
  return font

loadFontFromMemory :: String -> [Integer] -> Int -> [Int] -> Int -> WindowResources -> IO Font
loadFontFromMemory fileType fileData fontSize fontChars glyphCount wr = do
  font <- withCString fileType (\t -> withFreeableArrayLen (map fromIntegral fileData) (\size d -> withFreeableArray (map fromIntegral fontChars) (\c -> c'loadFontFromMemory t d (fromIntegral $ size * sizeOf (0 :: CUChar)) (fromIntegral fontSize) c (fromIntegral glyphCount)))) >>= pop
  addTextureId (texture'id $ font'texture font) wr
  return font

loadFontData :: [Integer] -> Int -> [Int] -> Int -> FontType -> IO GlyphInfo
loadFontData fileData fontSize fontChars glyphCount fontType = withFreeableArrayLen (map fromIntegral fileData) (\size d -> withFreeableArray (map fromIntegral fontChars) (\c -> c'loadFontData d (fromIntegral $ size * sizeOf (0 :: CUChar)) (fromIntegral fontSize) c (fromIntegral glyphCount) (fromIntegral $ fromEnum fontType))) >>= pop

genImageFontAtlas :: [GlyphInfo] -> [[Rectangle]] -> Int -> Int -> Int -> Int -> IO Image
genImageFontAtlas chars recs glyphCount fontSize padding packMethod = withFreeableArray chars (\c -> withFreeableArray2D recs (\r -> c'genImageFontAtlas c r (fromIntegral glyphCount) (fromIntegral fontSize) (fromIntegral padding) (fromIntegral packMethod))) >>= pop

-- | Unloads a font from GPU memory (VRAM). Fonts are automatically unloaded
-- when `closeWindow` is called, so manually unloading fonts is not required.
-- In larger projects, you may want to manually unload fonts to avoid having
-- them in VRAM for too long.
unloadFont :: Font -> WindowResources -> IO ()
unloadFont font = unloadSingleTexture (texture'id $ font'texture font)

isFontReady :: Font -> IO Bool
isFontReady font = toBool <$> withFreeable font c'isFontReady

exportFontAsCode :: Font -> String -> IO Bool
exportFontAsCode font fileName = toBool <$> withFreeable font (withCString fileName . c'exportFontAsCode)

drawFPS :: Int -> Int -> IO ()
drawFPS x y = c'drawFPS (fromIntegral x) (fromIntegral y)

drawText :: String -> Int -> Int -> Int -> Color -> IO ()
drawText text x y fontSize color = withCString text (\t -> withFreeable color (c'drawText t (fromIntegral x) (fromIntegral y) (fromIntegral fontSize)))

drawTextEx :: Font -> String -> Vector2 -> Float -> Float -> Color -> IO ()
drawTextEx font text position fontSize spacing tint = withFreeable font (\f -> withCString text (\t -> withFreeable position (\p -> withFreeable tint (c'drawTextEx f t p (realToFrac fontSize) (realToFrac spacing)))))

drawTextPro :: Font -> String -> Vector2 -> Vector2 -> Float -> Float -> Float -> Color -> IO ()
drawTextPro font text position origin rotation fontSize spacing tint = withFreeable font (\f -> withCString text (\t -> withFreeable position (\p -> withFreeable origin (\o -> withFreeable tint (c'drawTextPro f t p o (realToFrac rotation) (realToFrac fontSize) (realToFrac spacing))))))

drawTextCodepoint :: Font -> Int -> Vector2 -> Float -> Color -> IO ()
drawTextCodepoint font codepoint position fontSize tint = withFreeable font (\f -> withFreeable position (\p -> withFreeable tint (c'drawTextCodepoint f (fromIntegral codepoint) p (realToFrac fontSize))))

drawTextCodepoints :: Font -> [Int] -> Vector2 -> Float -> Float -> Color -> IO ()
drawTextCodepoints font codepoints position fontSize spacing tint = withFreeable font (\f -> withFreeableArrayLen (map fromIntegral codepoints) (\count cp -> withFreeable position (\p -> withFreeable tint (c'drawTextCodepoints f cp (fromIntegral count) p (realToFrac fontSize) (realToFrac spacing)))))

setTextLineSpacing :: Int -> IO ()
setTextLineSpacing = c'setTextLineSpacing . fromIntegral

measureText :: String -> Int -> IO Int
measureText text fontSize = fromIntegral <$> withCString text (\t -> c'measureText t (fromIntegral fontSize))

measureTextEx :: Font -> String -> Float -> Float -> IO Vector2
measureTextEx font text fontSize spacing = withFreeable font (\f -> withCString text (\t -> c'measureTextEx f t (realToFrac fontSize) (realToFrac spacing))) >>= pop

getGlyphIndex :: Font -> Int -> IO Int
getGlyphIndex font codepoint = fromIntegral <$> withFreeable font (\f -> c'getGlyphIndex f (fromIntegral codepoint))

getGlyphInfo :: Font -> Int -> IO GlyphInfo
getGlyphInfo font codepoint = withFreeable font (\f -> c'getGlyphInfo f (fromIntegral codepoint)) >>= pop

getGlyphAtlasRec :: Font -> Int -> IO Rectangle
getGlyphAtlasRec font codepoint = withFreeable font (\f -> c'getGlyphAtlasRec f (fromIntegral codepoint)) >>= pop

loadUTF8 :: [Integer] -> IO String
loadUTF8 codepoints =
  withFreeableArrayLen
    (map fromIntegral codepoints)
    ( \size c ->
        c'loadUTF8 c (fromIntegral size)
    )
    >>= popCString

loadCodepoints :: String -> IO [Int]
loadCodepoints text =
  withCString
    text
    ( \t ->
        withFreeable
          0
          ( \n -> do
              res <- c'loadCodepoints t n
              num <- peek n
              map fromIntegral <$> popCArray (fromIntegral num) res
          )
    )

getCodepointCount :: String -> IO Int
getCodepointCount text = fromIntegral <$> withCString text c'getCodepointCount

getCodepointNext :: String -> IO (Int, Int)
getCodepointNext text =
  withCString
    text
    ( \t ->
        withFreeable
          0
          ( \n ->
              do
                res <- c'getCodepointNext t n
                num <- peek n
                return (fromIntegral res, fromIntegral num)
          )
    )

getCodepointPrevious :: String -> IO (Int, Int)
getCodepointPrevious text =
  withCString
    text
    ( \t ->
        withFreeable
          0
          ( \n ->
              do
                res <- c'getCodepointPrevious t n
                num <- peek n
                return (fromIntegral res, fromIntegral num)
          )
    )

codepointToUTF8 :: Int -> IO String
codepointToUTF8 codepoint = withFreeable 0 (c'codepointToUTF8 $ fromIntegral codepoint) >>= peekCString
