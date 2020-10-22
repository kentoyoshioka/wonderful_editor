# == Schema Information
#
# Table name: comments
#
#  id         :bigint           not null, primary key
#  body       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  article_id :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_comments_on_article_id  (article_id)
#  index_comments_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (article_id => articles.id)
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe Comment, type: :model do
  let(:user) { create(:user) }
  let(:article) { create(:article, user_id: user.id) }

  context "body カラムに値が存在する時"
  it "コメントが投稿される" do
    comment = build(:comment, user_id: user.id, article_id: article.id)
    expect(comment).to be_valid
  end

  context "body カラムに値が存在しない時"
  it "コメントが投稿されない" do
    comment = build(:comment, body: "", user_id: user.id, article_id: article.id)
    expect(comment).to be_invalid
  end

  context "body カラムの文字数が 50 以上の時"
  it "文字数が多いのでコメントが投稿されない" do
    comment = build(:comment, body: "a" * 51, user_id: user.id, article_id: article.id)
    expect(comment).to be_invalid
  end
end
