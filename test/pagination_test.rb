# frozen_string_literal: true

require_relative "test_helper"

class PaginationTest < Minitest::Test
  class FakeTransport
    def initialize(pages)
      @pages = pages
    end

    def execute(_query, vars)
      { "sources" => @pages.fetch(vars["offset"] || 0) }
    end
  end

  def test_iterate_walks_every_page
    pages = {
      0 => { "nodes" => [{ "id" => "a" }, { "id" => "b" }], "pageInfo" => { "hasNextPage" => true } },
      2 => { "nodes" => [{ "id" => "c" }], "pageInfo" => { "hasNextPage" => false } },
    }
    svc = Hivehook::Resources::SourceService.new(FakeTransport.new(pages))
    assert_equal %w[a b c], svc.iterate.map { |n| n["id"] }
  end

  def test_iterate_single_page
    pages = { 0 => { "nodes" => [{ "id" => "only" }], "pageInfo" => { "hasNextPage" => false } } }
    svc = Hivehook::Resources::SourceService.new(FakeTransport.new(pages))
    assert_equal %w[only], svc.iterate.map { |n| n["id"] }
  end
end
