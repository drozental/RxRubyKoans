require_relative 'test_helper'

class AboutStreams < Minitest::Test
  def test_simple_subscription
    expected_result = 42
    stream = RxRuby::Observable.just(42)
    stream.subscribe {|x| assert_equal(expected_result, x) }
  end

  def test_what_comes_in_goes_out
    expected_result = 101
    stream = RxRuby::Observable.just(101)
    stream.subscribe {|x| assert_equal(x, expected_result) }
  end

  def test_same_as_event_stream
    expected_result = 37
    events = RxRuby::Subject.new
    source = events.as_observable
    source.subscribe {|x| assert_equal(expected_result, x) }
    events.on_next(37)
  end

  def test_how_event_relate_to_observables
    observable_result = 1
    RxRuby::Observable.just(73).subscribe {|x| observable_result = x }

    event_stream_result = 1
    events = RxRuby::Subject.new
    source = events.as_observable
    source.subscribe {|x| event_stream_result = x }
    events.on_next(73)

    assert_equal observable_result, event_stream_result
  end

  def test_event_stream_have_multiple_results
    expected_result = 17
    event_stream_result = 0
    events = RxRuby::Subject.new
    source = events.as_observable
    source.subscribe {|x| event_stream_result += x }

    events.on_next(10)
    events.on_next(7)

    assert_equal expected_result, event_stream_result
  end

  def test_simple_return
    expected_result = 'foo'
    received = ''
    RxRuby::Observable.just('foo').subscribe {|x| received = x }

    assert_equal expected_result, received
  end

  def test_the_last_event
    expected_result = 'bar'
    received = ''
    names = %w[foo bar]

    RxRuby::Observable.from(names).subscribe {|x| received = x }

    assert_equal expected_result, received
  end

  def test_everything_counts
    expected_result = 7
    received = 0
    numbers = [3,4]

    RxRuby::Observable.from(numbers).subscribe {|x| received += x }

    assert_equal expected_result, received
  end

  def test_this_is_still_an_event_stream
    expected_result = 15
    received = 0
    numbers = RxRuby::Subject.new
    source = numbers.as_observable

    source.subscribe {|x| received += x }

    numbers.on_next(10)
    numbers.on_next(5)

    assert_equal expected_result, received
  end

  def test_all_events_will_be_received
    expected_result = 'Working 98765'
    received = 'Working '
    numbers = Array(5..9).reverse

    RxRuby::Observable.from(numbers).subscribe {|x| received += x.to_s }

    assert_equal expected_result, received
  end
  #
  def test_do_things_in_the_middle
    expected_result = '4 = Party,3 = Party,2 = Party,1 = Study like mad'
    status = []
    range = Array(1..4).reverse
    days_till_test = RxRuby::Observable.from(range)

    # Erhm, is `do` the RxRuby's to RxJS's `tap` ?
    days_till_test.do {|d| status.push("#{d} = #{d == 1 ? 'Study like mad' : 'Party'}") }.subscribe

    assert_equal expected_result, status.join(',')
  end

  def test_nothing_listens_until_you_subscribe
    expected_result = 0
    sum = 0
    range = Array(1..10)
    numbers = RxRuby::Observable.from(range)

    observable = numbers.do {|x| sum += x }

    assert_equal expected_result, sum

    observable.subscribe
    expected_result = 55
    assert_equal expected_result, sum
  end

  def test_events_after_you_unsubscribe_dont_count
    expected_result = 3
    sum = 0
    numbers = RxRuby::Subject.new

    numbers_source = numbers.as_observable
    observable = numbers_source.do {|n| sum += n}
    subscription = observable.subscribe

    numbers.on_next(1)
    numbers.on_next(2)

    subscription.dispose

    numbers.on_next(3)
    numbers.on_next(4)

    assert_equal expected_result, sum
  end

  def test_events_while_subscribing
    expected_result = 'you look pretty'
    received = []
    words = RxRuby::Subject.new
    words_source = words.as_observable

    observable = words_source.do {|x| received.push(x) }

    words.on_next('Peter')
    words.on_next('said')

    subscription = observable.subscribe

    words.on_next('you')
    words.on_next('look')
    words.on_next('pretty')

    subscription.dispose

    words.on_next('ugly')

    assert_equal expected_result, received.join(' ')
  end

end
