require_relative 'test_helper'
require "event_emitter"

class FooEmitter
  include EventEmitter
end

class AboutQuerying < Minitest::Test

  def test_basic_querying
    strings = []
    numbers = RxRuby::Observable.range(1, 100)

    numbers
      .select {|num| num % 11 == 0 }
      .map {|num| num.to_s }
      .subscribe {|string| strings.push(string) }

    expected_result = '11,22,33,44,55,66,77,88,99'
    assert_equal expected_result, strings.join(',')
  end

  def test_querying_over_events
    # FIXME
    skip "Event wrapping not available, yet."

    results = 0
    e = FooEmitter.new

    RxRuby::Observable.from_event(e, 'click')
      .select {|click| click[:x] == click[:y] }
      .map {|click| click[:x] + click[:y] }
      .subscribe {|r| results = r }

    e.emit('click', {x: 100, y: 50})
    e.emit('click', {x: 75,  y: 75})
    e.emit('click', {x: 40,  y: 80})

    assert_equal 150, results
  end

  def test_buffering_with_count_and_skip
    results = []

    RxRuby::Observable
      .range(1, 10)
      .buffer_with_count(5, 6)
      .subscribe {|r| results.push(r) }

    expected_result_1 = '12345'
    expected_result_2 = '78910'
    expected_result_3 = nil

    #http://reactivex.io/rxjs/class/es6/Observable.js~Observable.html#instance-method-bufferCount
    assert_equal expected_result_1,  results[0].join
    assert_equal expected_result_2, results[1].join
    # assert_equal expected_result_3, results[2].join
  end
end
