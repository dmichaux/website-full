require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

	def setup
		@user = users(:adam)
	end

	test "login with invalid credentials" do
		get login_path
		assert_template "sessions/new"
		post login_path, params: { session: { email: 		"",
																					password: "" } }
		assert_not is_logged_in?
		assert_template "sessions/new"
		assert_not flash.empty?
		get root_path
		assert flash.empty?
	end

	test "login before account is active" do
		@user.toggle!(:activated)
		post login_path, params: {session: { email: 	 @user.email,
																				 password: 'Password1' } }
		assert_not is_logged_in?
	end

	test "login with valid credentials, followed by logout" do
		get login_path
		post login_path, params: {session: { email: 	 @user.email,
																				 password: 'Password1' } }
		assert is_logged_in?
		assert_redirected_to @user
		follow_redirect!
		assert_template "users/show"
		assert_select "a[href=?]", login_path, count: 0
		assert_select "a[href=?]", logout_path
		delete logout_path
		assert_not is_logged_in?
		assert_redirected_to root_path
		# Simulate user logging out via second window
		delete logout_path
		follow_redirect!
		assert_select "a[href=?]", login_path
		assert_select "a[href=?]", logout_path, count: 0
	end

	test "login with remembering" do
		log_in_as(@user, remember_me: '1')
		assert_not_empty cookies['remember_token']
	end

	test "login without remembering" do
		# Login to set cookie
		log_in_as(@user, remember_me: '1')
		# Login again and confirm cookie is deleted
		log_in_as(@user, remember_me: '0')
		assert_empty cookies['remember_token']
	end
end
