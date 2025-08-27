require "test_helper"

class Ai::QuotaTest < ActiveSupport::TestCase
  setup do
    @quota = Ai::Quota.new(user: users(:jz), limit: Ai::Quota::Money.wrap("$100").in_microcents)
  end

  test "create" do
    assert @quota.save

    assert_in_delta 7.days.from_now, @quota.reset_at, 1.minute
    assert_equal 0, @quota.used
    assert_equal Ai::Quota::Money.wrap("$100").in_microcents, @quota.limit
  end

  test "increment usage" do
    @quota.save

    @quota.spend("$100")
    assert_equal Ai::Quota::Money.wrap("$100").in_microcents, @quota.used
    @quota.spend("$500")
    assert_equal Ai::Quota::Money.wrap("$600").in_microcents, @quota.used
    @quota.spend("$1000")
    assert_equal Ai::Quota::Money.wrap("$1600").in_microcents, @quota.used
    @quota.spend("$5000")
    assert_equal Ai::Quota::Money.wrap("$6600").in_microcents, @quota.used
    @quota.spend("$10000")
    assert_equal Ai::Quota::Money.wrap("$16600").in_microcents, @quota.used

    @quota.used = 0

    @quota.spend("$10")
    assert_equal Ai::Quota::Money.wrap("$10").in_microcents, @quota.used
    assert_in_delta 7.days.from_now, @quota.reset_at, 1.minute

    travel 2.days

    @quota.spend("$5")
    assert_equal Ai::Quota::Money.wrap("$15").in_microcents, @quota.used
    assert_in_delta 5.days.from_now, @quota.reset_at, 1.minute

    travel 8.days

    @quota.spend("$5")
    assert_equal Ai::Quota::Money.wrap("$5").in_microcents, @quota.used
    assert_in_delta 7.days.from_now, @quota.reset_at, 1.minute
  end

  test "limit checks" do
    @quota.save

    @quota.used = 0
    @quota.ensure_not_depleted

    @quota.used = Ai::Quota::Money.wrap("$300").in_microcents
    assert_raises Ai::Quota::UsageExceedsQuotaError do
      @quota.ensure_not_depleted
    end

    travel 10.days
    @quota.ensure_not_depleted
  end
end
