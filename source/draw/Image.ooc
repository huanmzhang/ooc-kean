/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
use base
use draw

Image: abstract class {
	_size: IntVector2D
	_referenceCount: ReferenceCounter
	size ::= this _size
	width ::= this size x
	height ::= this size y
	referenceCount ::= this _referenceCount
	init: func (=_size) {
		this _referenceCount = ReferenceCounter new(this)
	}
	free: override func {
		if (this referenceCount != null)
			this referenceCount free()
		this _referenceCount = null
		super()
	}
	drawPoint: virtual func (position: FloatPoint2D, pen: Pen = Pen new(ColorRgba white)) {
		list := VectorList<FloatPoint2D> new()
		list add(position)
		this drawPoints(list, pen)
		list free()
	}
	drawLine: virtual func (start, end: FloatPoint2D, pen: Pen = Pen new(ColorRgba white)) {
		list := VectorList<FloatPoint2D> new()
		list add(start) . add(end)
		this drawLines(list, pen)
		list free()
	}
	drawPoints: virtual func (pointList: VectorList<FloatPoint2D>, pen: Pen = Pen new(ColorRgba white)) { raise("drawPoints unimplemented for class %s!" format(this class name)) }
	drawLines: virtual func (pointList: VectorList<FloatPoint2D>, pen: Pen = Pen new(ColorRgba white)) { raise("drawLines unimplemented for class %s!" format(this class name)) }
	drawBox: virtual func (box: FloatBox2D, pen: Pen = Pen new(ColorRgba white)) {
		positions := VectorList<FloatPoint2D> new()
		positions add(box leftTop)
		positions add(box rightTop)
		positions add(box rightBottom)
		positions add(box leftBottom)
		positions add(box leftTop)
		this drawLines(positions, pen)
		positions free()
	}
	fill: virtual func (color: ColorRgba) { raise("fill unimplemented for class %s!" format(this class name)) }
	draw: virtual func ~DrawState (drawState: DrawState) { Debug error("draw~DrawState unimplemented for class %s!" format(this class name)) }
	resizeWithin: func (restriction: IntVector2D) -> This {
		restrictionFraction := (restriction x as Float / this size x as Float) minimum(restriction y as Float / this size y as Float)
		this resizeTo((this size toFloatVector2D() * restrictionFraction) toIntVector2D())
	}
	resizeTo: abstract func (size: IntVector2D) -> This
	resizeTo: virtual func ~withMethod (size: IntVector2D, Interpolate: Bool) -> This {
		this resizeTo(size)
	}
	create: virtual func (size: IntVector2D) -> This { raise("create unimplemented for class %s!" format(this class name)); null }
	copy: abstract func -> This
	distance: virtual abstract func (other: This) -> Float
	equals: func (other: This) -> Bool { this size == other size && this distance(other) < 10 * Float epsilon }
	isValidIn: func (x, y: Int) -> Bool {
		x >= 0 && x < this size x && y >= 0 && y < this size y
	}
	// Writes white text on the existing image
	write: virtual func (message: Text, fontAtlas: This, localOrigin: IntPoint2D) {
		takenMessage := message take()
		skippedRows := 2
		visibleRows := 6
		columns := 16
		fontSize := DrawContext getFontSize(fontAtlas)
		viewport := IntBox2D new(localOrigin, fontSize)
		targetOffset := IntPoint2D new(0, 0)
		characterDrawState := DrawState new(this) setInputImage(fontAtlas) setBlendMode(BlendMode White)
		for (i in 0 .. takenMessage count) {
			charCode := takenMessage[i] as Int
			sourceX := charCode % columns
			sourceY := (charCode / columns) - skippedRows
			source := FloatBox2D new((sourceX as Float) / columns, (sourceY as Float) / visibleRows, 1.0f / columns, 1.0f / visibleRows)
			if ((charCode as Char) graph())
				characterDrawState setViewport(viewport + (targetOffset * fontSize)) setSourceNormalized(source) draw()
			targetOffset x += 1
			if (charCode == '\n') {
				targetOffset x = 0 // Carriage return
				targetOffset y += 1 // Line feed
			}
		}
		message free(Owner Receiver)
	}
}
