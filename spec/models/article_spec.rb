# == Schema Information
#
# Table name: articles
#
#  id         :bigint           not null, primary key
#  body       :text
#  status     :integer          default("draft")
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
  describe "正常系" do
    context "title, body カラムに値がある時" do
      let(:article) { build(:article) }

      it "下書き状態の記事が登録される" do
        expect(article).to be_valid
        expect(article.status).to eq("draft")
      end

      it "公開記事だけ取得できる" do
        article = build(:article, status: "published")
        expect(article).to be_valid
        expect(article.status).to eq("published")
      end

      it "下書き記事だけ取得できる" do
        article = build(:article, status: "draft")
        expect(article).to be_valid
        expect(article.status).to eq("draft")
      end
    end
  end

  describe "異常系" do
    context "title カラムに値がない時" do
      it "タイトルがないので記事は登録されない" do
        article = build(:article, title: nil)
        expect(article).to be_invalid
        expect(article.errors.messages[:title]).to include "can't be blank"
      end
    end

    context "title カラムの値が 20 以上の時" do
      it "タイトルの文字数が 20 字以上なので記事は登録されない" do
        article = build(:article, title: "poiuytrewqasdfghjklmnbvc")
        expect(article).to be_invalid
        expect(article.errors.messages[:title]).to include "is too long (maximum is 20 characters)"
      end
    end

    context "body カラムに値がない時" do
      it "記事の内容がないので記事は登録されない" do
        article = build(:article, body: nil)
        expect(article).to be_invalid
        expect(article.errors.messages[:body]).to include "can't be blank"
      end
    end
  end
end
