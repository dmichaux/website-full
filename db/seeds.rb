# Delete previous seeds in Development
if Rails.env.development?
	User.destroy_all
	Cohort.destroy_all
	OutsideMessage.destroy_all
end


admin = User.create(name: "Admin", email: "admin@example.com", admin: true,
										activated: true, activated_at: 1.year.ago)
admin.password = admin.password_confirmation = "Password1"
admin.save

User.create(name: "Uncactivated User", email: "inactive@example.com")

lorem = "Lorem ipsum dolor sit amet, consectetur adipisicing elit,
					 sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."

("A".."G").each do |x|

	# Users

	user = User.create(name: "Test #{x}", email: "test#{x}@example.com",
										 activated: true, activated_at: Time.zone.now)
	user.password = user.password_confirmation = "Password1"
	user.save

	# User Goals

	3.times do |n|
		user.goals.create(body: "Goal #{n + 1}: #{lorem[0..25]}")
	end

	# Cohorts

	Cohort.create(name: "Cohort #{x}",
								description: "Description for Cohort #{x}: #{lorem}",
								start_date: Date.today, end_date: (Date.today + 8.weeks))

	# Messages

	2.times do |n|
		admin.sent_messages.create(to_user_id: user.id,
															 body: "Message #{n+1} to Test #{x}. #{lorem}")
	end
	user.sent_messages.create(to_user_id: admin.id,
														body: "Dear Admin. #{lorem}")

	# Outside Messages

	OutsideMessage.create(name: "Visitor #{x}", email: "Visitor#{x}@example.com",
												to_admin_id: admin.id, body: "#{lorem}")
end
