/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use concurrent

_PromiseState: enum {
	Unfinished
	Finished
	Cancelled
}

Promise: abstract class {
	_state: _PromiseState
	init: func
	wait: abstract func -> Bool
	wait: abstract func ~timeout (time: TimeSpan) -> Bool
	cancel: virtual func -> Bool { false }
	start: static func (action: Func) -> This { _ThreadPromise new(action) }
	empty: static This { get { _EmptyPromise new() } }
}

_EmptyPromise: class extends Promise {
	init: func { super() }
	wait: override func -> Bool { true }
	wait: override func ~timeout (time: TimeSpan) -> Bool { true }
}

_ThreadPromise: class extends Promise {
	_action: Func
	_thread: Thread
	_threadAlive := true
	_freeOnCompletion := false
	init: func (task: Func) {
		super()
		this _state = _PromiseState Unfinished
		this _action = func {
			task()
			if (this _state != _PromiseState Cancelled)
				this _state = _PromiseState Finished
			if (this _freeOnCompletion) {
				this _threadAlive = false
				this free()
			}
		}
		this _thread = Thread new(this _action)
		this _thread start()
	}
	free: override func {
		if (this _threadAlive) {
			this _freeOnCompletion = true
			this _thread detach()
		} else {
			this _thread free()
			(this _action as Closure) free()
			super()
		}
	}
	wait: override func -> Bool {
		if (this _threadAlive)
			if (this _thread wait())
				this _threadAlive = false
		this _state == _PromiseState Finished
	}
	wait: override func ~timeout (time: TimeSpan) -> Bool {
		if (this _threadAlive)
			if (this _thread wait(time toSeconds()))
				this _threadAlive = false
		this _state == _PromiseState Finished
	}
	cancel: override func -> Bool {
		if (this _state == _PromiseState Unfinished) {
			this _thread cancel()
			this _state = _PromiseState Cancelled
		}
		this _state == _PromiseState Cancelled
	}
}

Future: abstract class <T> {
	_state: _PromiseState
	init: func
	wait: abstract func -> Bool
	wait: abstract func ~timeout (time: TimeSpan) -> Bool
	wait: virtual func ~default (defaultValue: T) -> T {
		status := this wait()
		status ? this getResult(defaultValue) : defaultValue
	}
	wait: virtual func ~defaulttimeout (time: TimeSpan, defaultValue: T) -> T {
		status := this wait(time)
		status ? this getResult(defaultValue) : defaultValue
	}
	getResult: abstract func (defaultValue: T) -> T
	cancel: virtual func -> Bool { false }
	start: static func<S> (S: Class, action: Func -> S) -> This<S> {
		_ThreadFuture<S> new(action)
	}
}

_ThreadFuture: class <T> extends Future<T> {
	_result: __onheap__ T
	_action: Func
	_thread: Thread
	_threadAlive := true
	_freeOnCompletion := false
	init: func (task: Func -> T) {
		super()
		this _state = _PromiseState Unfinished
		this _action = func {
			temporary := task()
			this _result = temporary
			if (this _state != _PromiseState Cancelled)
				this _state = _PromiseState Finished
			if (this _freeOnCompletion) {
				this _threadAlive = false
				this free()
			}
		}
		this _thread = Thread new(this _action)
		this _thread start()
	}
	free: override func {
		if (this _threadAlive) {
			this _freeOnCompletion = true
			this _thread detach()
		} else {
			memfree(this _result)
			this _thread free()
			(this _action as Closure) free()
			super()
		}
	}
	wait: override func -> Bool {
		if (this _threadAlive)
			if (this _thread wait())
				this _threadAlive = false
		this _state == _PromiseState Finished
	}
	wait: override func ~timeout (time: TimeSpan) -> Bool {
		if (this _threadAlive)
			if (this _thread wait(time toSeconds()))
				this _threadAlive = false
		this _state == _PromiseState Finished
	}
	getResult: override func (defaultValue: T) -> T {
		result := defaultValue
		if (this _state == _PromiseState Finished && this _result != null)
			result = this _result
		result
	}
	cancel: override func -> Bool {
		if (this _state == _PromiseState Unfinished) {
			this _thread cancel()
			this _state = _PromiseState Cancelled
		}
		this _state == _PromiseState Unfinished
	}
}
