require 'test_helper'

module ResqueWeb
  class JobsControllerTest < ActionController::TestCase
    include ControllerTestHelpers

    let(:queue_name) { 'example_queue' }
    let(:args)       { ['foo', 'bar'] }
    let(:params)     { { queue: queue_name, job_class: 'ExampleJob', args: JSON.dump(args)} }

    setup do
      @routes = Engine.routes
      Resque.push(queue_name, class: 'ExampleJob', args: args)
      @queue_size = Resque.size(queue_name)
    end

    teardown do
      Resque.remove_queue(queue_name)
    end

    describe "DELETE /destroy" do
      let(:params_without_args) do
        params.merge(:args => JSON.dump([]))
      end

      it "deletes a job having the specified arguments" do
        visit(:destroy, params, method: :delete)
        new_queue_size = Resque.size(queue_name)
        assert_equal((@queue_size - 1), new_queue_size)
      end

      it "deletes all jobs of a class if no args are specified" do
        Resque.push(queue_name, class: 'ExampleJob')
        visit(:destroy, params_without_args, method: :delete)
        new_queue_size = Resque.size(queue_name)
        assert_equal(0, new_queue_size)
      end

      it "redirects to the queue's show page" do
        visit(:destroy, params, method: :delete)
        assert_redirected_to queue_path(queue_name)
      end
    end
  end
end
