package karate.user;

import com.intuit.karate.junit5.Karate;
import de.hsrm.vegetables.service.Application;
import karate.BaseTest;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.context.TestPropertySource;

@SpringBootTest(
        webEnvironment = WebEnvironment.DEFINED_PORT,
        classes = Application.class
)
@TestPropertySource(
        properties = {
                "server.port: 8090",
                "vegetables.jwt.secret: THIS:IS:A:JWT:SECRET",
                "vegetables.jwt.lifetime: 60000",
                "vegetables.jwt.refreshLifetime: 60000"
        }
)

@DirtiesContext
@AutoConfigureMockMvc
public class UserTest extends BaseTest {

    @Karate.Test
    Karate testAll() {
        return Karate.run()
                .relativeTo(getClass());
    }

}
