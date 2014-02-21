<?php
/**
 * Implements hook_form_alter().
 *
 * Allows the profile to alter the site configuration form.
 */
function business_form_install_configure_form_alter(&$form, $form_state) {
  // When using Drush, let it set the default password.
  if (drupal_is_cli()) {
    return;
  }
  // Domyslne ustawienia dla developerów - ustawienia witryny.
  $form['site_information']['site_name']['#title'] = 'Store name';
  $form['site_information']['site_mail']['#title'] = 'Store email address';
  $form['site_information']['site_name']['#default_value'] = st('Drupal Business');

  // Ustawienie usera domyślnego na "admin".
  $form['admin_account']['account']['name']['#default_value'] = 'admin';

  // Ustawienie domyślnego hasła na "business".
  $form['admin_account']['account']['pass']['#value'] = 'business';

  // Ukrycie standardowego formularza z kontem.
  $form['update_notifications']['#access'] = FALSE;

  // Dodanie danych do konta (login i hasło).
  $form['admin_account']['account']['business_name'] = array(
    '#type' => 'item',
    '#title' => st('Username'),
    '#markup' => 'admin'
  );
  $form['admin_account']['account']['business_password'] = array(
    '#type' => 'item',
    '#title' => st('Password'),
    '#markup' => 'business'
  );
  $form['admin_account']['account']['business_informations'] = array(
    '#markup' => '<p>' . t('The data will be sent to the main site address.') . '</p>'
  );
  $form['admin_account']['override_account_informations'] = array(
    '#type' => 'checkbox',
    '#title' => t('Change my username and password.'),
  );
  $form['admin_account']['setup_account'] = array(
    '#type' => 'container',
    '#parents' => array('admin_account'),
    '#states' => array(
      'invisible' => array(
        'input[name="override_account_informations"]' => array('checked' => FALSE),
      ),
    ),
  );

  // Skopiowanie zawartości do formularza konta
  $form['admin_account']['setup_account']['account']['name'] = $form['admin_account']['account']['name'];
  $form['admin_account']['setup_account']['account']['pass'] = $form['admin_account']['account']['pass'];
  $form['admin_account']['setup_account']['account']['pass']['#value'] = array('pass1' => 'business', 'pass2' => 'business');

  // Ustawienie "admin" jako konta domyslnego.
  $form['admin_account']['account']['name']['#access'] = FALSE;

  //Ukrycie hasła.
  $form['admin_account']['account']['pass']['#type'] = 'hidden';
  $form['admin_account']['account']['mail']['#access'] = FALSE;

  // Ustawienie opcji dodania adresu głównego do konta admina
  array_unshift($form['#validate'], 'business_custom_setting');
}

/**
 * Walidacja ustawień konta admina
 */
function business_custom_setting(&$form, &$form_state) {
  $form_state['values']['account']['mail'] = $form_state['values']['site_mail'];
  // Use our custom values only the corresponding checkbox is checked.
  if ($form_state['values']['override_account_informations'] == TRUE) {
    if ($form_state['input']['pass']['pass1'] == $form_state['input']['pass']['pass2']) {
      $form_state['values']['account']['name'] = $form_state['values']['name'];
      $form_state['values']['account']['pass'] = $form_state['input']['pass']['pass1'];
    }
    else {
      form_set_error('pass', st('The specified passwords do not match.'));
    }
  }
}
