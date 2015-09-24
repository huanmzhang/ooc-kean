/*
 * Copyright (C) 2014 - Simon Mika <simon@mika.se>
 *
 * This sofware is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with This software. If not, see <http://www.gnu.org/licenses/>.
 */

import include/gles3
import ../GLQuad
import Gles3VertexArrayObject, Gles3Debug

Gles3Quad: class extends GLQuad {
	init: func {
		version(debugGL) { validateStart() }
		positions := [-1.0f, -1.0f, -1.0f, 1.0f, 1.0f, -1.0f, 1.0f, 1.0f] as Float*
		textureCoordinates := [0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f, 0.0f] as Float*
		this vao = Gles3VertexArrayObject new(positions, textureCoordinates, 4, 2)
		version(debugGL) { validateEnd("quad init") }
	}
	free: override func {
		this vao free()
		super()
	}
	draw: func {
		version(debugGL) { validateStart() }
		this vao bind()
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4)
		this vao unbind()
		version(debugGL) { validateEnd("quad draw") }
	}
}
