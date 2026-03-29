package com.corso.devops.corsontt38.config;

import static org.assertj.core.api.Assertions.assertThat;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;

/**
 * Test per SecurityConfig.
 * Verifica la configurazione di Spring Security.
 */
@SpringBootTest
class SecurityConfigSimpleTest {

    @Autowired
    private SecurityConfig securityConfig;

    @Autowired
    private UserDetailsService userDetailsService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    // ========================================================================
    // TEST BEAN Configuration
    // ========================================================================

    @Test
    void securityConfigBean_shouldBeLoaded() {
        assertThat(securityConfig).isNotNull();
    }

    @Test
    void userDetailsServiceBean_shouldBeLoaded() {
        assertThat(userDetailsService).isNotNull();
    }

    @Test
    void passwordEncoderBean_shouldBeLoaded() {
        assertThat(passwordEncoder).isNotNull();
    }

    @Test
    void passwordEncoder_shouldBeBCrypt() {
        assertThat(passwordEncoder.getClass().getSimpleName())
            .isEqualTo("BCryptPasswordEncoder");
    }

    // ========================================================================
    // TEST USER DETAILS
    // ========================================================================

    @Test
    void userDetailsService_shouldLoadUserByUsername() {
        UserDetails user = userDetailsService.loadUserByUsername("user");
        
        assertThat(user).isNotNull();
        assertThat(user.getUsername()).isEqualTo("user");
        assertThat(user.getAuthorities()).isNotEmpty();
    }

    @Test
    void userDetailsService_shouldLoadAdminByUsername() {
        UserDetails admin = userDetailsService.loadUserByUsername("admin");
        
        assertThat(admin).isNotNull();
        assertThat(admin.getUsername()).isEqualTo("admin");
        assertThat(admin.getAuthorities()).hasSize(2); // USER + ADMIN
    }

    @Test
    void userDetailsService_shouldLoadMarioByUsername() {
        UserDetails mario = userDetailsService.loadUserByUsername("mario");
        
        assertThat(mario).isNotNull();
        assertThat(mario.getUsername()).isEqualTo("mario");
    }

    @Test
    void userPassword_shouldBeEncoded() {
        UserDetails user = userDetailsService.loadUserByUsername("user");
        
        assertThat(user.getPassword()).isNotNull();
        assertThat(user.getPassword()).startsWith("$2"); // BCrypt prefix
    }

    @Test
    void passwordEncoder_shouldMatchCorrectPassword() {
        UserDetails user = userDetailsService.loadUserByUsername("user");
        
        boolean matches = passwordEncoder.matches("user123", user.getPassword());
        
        assertThat(matches).isTrue();
    }

    @Test
    void passwordEncoder_shouldNotMatchWrongPassword() {
        UserDetails user = userDetailsService.loadUserByUsername("user");
        
        boolean matches = passwordEncoder.matches("wrongpassword", user.getPassword());
        
        assertThat(matches).isFalse();
    }

    @Test
    void adminUser_shouldHaveUserRole() {
        UserDetails admin = userDetailsService.loadUserByUsername("admin");
        
        boolean hasUserRole = admin.getAuthorities().stream()
            .anyMatch(auth -> auth.getAuthority().equals("ROLE_USER"));
        
        assertThat(hasUserRole).isTrue();
    }

    @Test
    void adminUser_shouldHaveAdminRole() {
        UserDetails admin = userDetailsService.loadUserByUsername("admin");
        
        boolean hasAdminRole = admin.getAuthorities().stream()
            .anyMatch(auth -> auth.getAuthority().equals("ROLE_ADMIN"));
        
        assertThat(hasAdminRole).isTrue();
    }

    @Test
    void regularUser_shouldOnlyHaveUserRole() {
        UserDetails user = userDetailsService.loadUserByUsername("user");
        
        long roleCount = user.getAuthorities().stream()
            .filter(auth -> auth.getAuthority().startsWith("ROLE_"))
            .count();
        
        assertThat(roleCount).isEqualTo(1);
    }

    @Test
    void passwordEncoder_shouldEncodePassword() {
        String rawPassword = "testPassword123";
        String encoded = passwordEncoder.encode(rawPassword);
        
        assertThat(encoded).isNotEqualTo(rawPassword);
        assertThat(passwordEncoder.matches(rawPassword, encoded)).isTrue();
    }

    @Test
    void passwordEncoder_shouldProduceDifferentHashesForSamePassword() {
        String rawPassword = "samePassword";
        String encoded1 = passwordEncoder.encode(rawPassword);
        String encoded2 = passwordEncoder.encode(rawPassword);
        
        // BCrypt includes salt, so hashes differ
        assertThat(encoded1).isNotEqualTo(encoded2);
        assertThat(passwordEncoder.matches(rawPassword, encoded1)).isTrue();
        assertThat(passwordEncoder.matches(rawPassword, encoded2)).isTrue();
    }
}
