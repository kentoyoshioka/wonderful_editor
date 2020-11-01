require "rails_helper"

RSpec.describe "Api::V1::Articles", type: :request do
  describe "GET /articles" do
    subject { get(api_v1_articles_path) }

    let!(:article1) { create(:article, updated_at: 1.days.ago) }
    let!(:article2) { create(:article, updated_at: 2.days.ago) }
    let!(:article3) { create(:article) }

    context "正常系" do
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
  end
end
