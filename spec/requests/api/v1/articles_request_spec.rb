require "rails_helper"

RSpec.describe "Api::V1::Articles", type: :request do
  describe "GET /articles" do
    subject { get(api_v1_articles_path) }

    let!(:article1) { create(:article, updated_at: 1.days.ago) }
    let!(:article2) { create(:article, updated_at: 2.days.ago) }
    let!(:article3) { create(:article) }

    it "記事一覧の表示" do
      subject

      json = JSON.parse(response.body)
      # binding.pry
      expect(json.length).to eq(3)
      expect(response.status).to eq(200)
      expect(json.map {|h| h["id"] }).to eq [article3.id, article1.id, article2.id]
      expect(json[0].keys).to eq ["id", "title", "updated_at", "user"]
      expect(json[0]["user"].keys).to eq ["id", "name", "email"]
    end
  end

  describe "GET /articles/:id" do
    subject { get(api_v1_article_path(article_id)) }

    context "指定した id の記事が存在する場合" do
      let(:article_id) { article.id }
      let(:article) { create(:article) }

      it "記事のタイトル、内容を取得する" do
        subject

        json = JSON.parse(response.body)

        expect(json["id"]).to eq article.id
        expect(json["title"]).to eq article.title
        expect(json["body"]).to eq article.body
        expect(json["updated_at"]).to be_present
        expect(json["user"]["id"]).to eq article.user.id
        expect(json["user"].keys).to eq ["id", "name", "email"]
        expect(response.status).to eq(200)
      end
    end

    context "指定した id の記事が存在しない場合" do
      let(:article_id) { 1_000_000 }

      it "記事が見つからない" do
        expect { subject }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
