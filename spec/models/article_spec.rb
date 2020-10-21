# == Schema Information
#
# Table name: articles
#
#  id         :bigint           not null, primary key
#  body       :text
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_articles_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe Article, type: :model do
  before do
    @user = create(:user)
  end

  context "title, body, user_id カラムに値がある時"
  it "記事が登録される" do
    article = build(:article, user_id: @user.id)
    expect(article).to be_valid
  end

  context "title カラムに値がない時"
  it "タイトルがないので記事は登録されない" do
    article = build(:article, title: "", user_id: @user.id)
    expect(article).to be_invalid
  end

  context "title カラムの値が 20 以上の時"
  it "タイトルの文字数が 20 字以上なので記事は登録されない" do
    article = build(:article, title: "poiuytrewqasdfghjklmnbvc", user_id: @user.id)
    expect(article).to be_invalid
  end

  context "body カラムに値がない時"
  it "記事の内容がないので記事は登録されない" do
    article = build(:article, body: "", user_id: @user.id)
    expect(article).to be_invalid
  end
end
