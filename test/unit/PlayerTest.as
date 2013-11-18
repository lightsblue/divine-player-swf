/**
 * NOTE: Tests have to be manually added to Suite.as
 */
package {
  import asunit.framework.TestCase;

  public class PlayerTest extends TestCase {

    public function PlayerTest(testMethod: String) {
      super(testMethod);
    }

    public function testPass(): void {
      assertTrue("Passing test", true);
    }

  }

}
