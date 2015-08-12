/*
* Copyright (C) 2015 - Simon Mika <simon@mika.se>
*
* This sofware is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
*
* This software is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with this software. If not, see <http://www.gnu.org/licenses/>.
*/
use ooc-collections

StringBuilder: class {
	_stringList := VectorList<String> new()

	count ::= this _stringList count

	init: func ~default
	init: func ~string (value: String) {
		this init()
		this append(value)
	}
	init: func ~this (original: This) {
		this init()
		original _stringList apply( func (value: String) { this append(value) })
	}
	free: func {
		_stringList free()
		super()
	}
	copy: func -> This {
		This new(this)
	}

	append: func ~String (value: String) {
		this _stringList add(value clone())
	}
	append: func ~This (other: This) {
		for (i in 0..other count)
			this append(other[i])
	}
	prepend: func ~String (value: String) {
		this _stringList insert(0, value clone())
	}
	prepend: func ~This (other: This) {
		for (i in 0..other count)
			prepend(other[other count -1 -i])
	}

	toString: func -> String {
		result := ""
		for (i in 0..this _stringList count)
			result = result >> this _stringList[i]
		result
	}
	println: func {
		this toString() println().free()
	}

	operator [] (index: Int) -> String {
		this _stringList[index]
	}
	operator []= (index: Int, value: String) {
		this _stringList[index] = value
	}
	operator + (other: This) -> This {
		result := This new(this)
		result append(other)
		result
	}
	operator + (value: String) -> This {
		result := This new (this)
		result append(value)
		result
	}
}
operator + (value: String, stringBuilder: StringBuilder) -> StringBuilder {
	result := StringBuilder new (stringBuilder)
	result prepend(value)
	result
}
