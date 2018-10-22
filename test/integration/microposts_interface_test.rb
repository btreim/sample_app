require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
	def setup
		@user = users(:ben)
	end

	test "micropost interface" do 
		log_in_as(@user)
		get root_path
		assert_select 'div.pagination'
		assert_select 'input[type=file]'
		#invalid submission
		assert_no_difference "Micropost.count" do
			post microposts_path, params: { micropost: { content: "  " }} 
		end
		assert_select 'div#error_explanation'


		#valid submission
		content = "This is some really nice avacado toast"
		picture = fixture_file_upload('test/fixtures/rails.png', 'image/png')
		assert_difference "Micropost.count", 1 do
			post microposts_path, params: { micropost: { content: content,
																									 picture: picture }} 
		end
		assert_redirected_to root_url
		micropost = assigns(:micropost)
		assert micropost.picture
		follow_redirect!
		assert_select 'a', text: 'delete'
		first_micropost = @user.microposts.paginate(page:1).first
		assert_difference 'Micropost.count', -1 do 
			delete micropost_path(first_micropost)
		end

		# Visit different user (no delete link)

		get user_path(users(:archer))
		assert_select 'a', text: 'delete', count: 0
	end

	test "micropost sidebar count" do 
		log_in_as(users(:ben))
		get root_path
		assert_match '34 microposts', response.body
		#Zero microposts
		other_user = users(:malory)
		log_in_as(other_user)
		get root_path
		assert_match '0 microposts', response.body
		#create micropost
		other_user.microposts.create!(content:"A micropost")
		get root_path
		assert_match '1 micropost', response.body
	end
end
