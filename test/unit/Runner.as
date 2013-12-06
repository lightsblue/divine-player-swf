package {
  import asunit.textui.TestRunner;

  public class Runner extends TestRunner {
    public function Runner() {
      start(Suite, null, TestRunner.SHOW_TRACE);
    }
  }
}
