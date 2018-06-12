require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name:"Example", email:"bt@mail.com",
    				 password: "foobar", password_confirmation: "foobar")
  end

  test "user should be valid" do
    assert @user.valid? 
  end


  test "name should be present" do
    @user.name = "    "
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email shold be present" do
    @user.email = " "
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@google.com USER@foo.COM A-us_er@foo.bar.org
							 first.last@foo.jp alice+bpb@bac.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@me,com user_at_foo.org user.name@example.
  						   foo@bar+baz.com user@foo..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should not be valid"
    end
  end

  test "email addresses should be unique" do 
  	duplicate = @user.dup
  	duplicate.email = @user.email.upcase
  	@user.save
  	assert_not duplicate.valid?
  end

  test "email address should be converted to downcase before save" do 
  	upcase_email = %w[fEkl@bar.cOm TEST@ME.COM down@case.net]
  	upcase_email.each do | email |
  		@user.email = email
  		@user.save
  		assert_equal email.downcase, @user.reload.email, "#{email} should be valid"
  	end
  end

  test "password should not be blank" do 
  	@user.password = @user.password_confirmation = " " * 6
  	assert_not @user.valid?
  end

  test "password should have a minimum length" do
  	@user.password = @user.password_confirmation = "a" * 5
  	assert_not @user.valid?
  end

end
