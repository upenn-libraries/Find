export declare class Header {
  isMenuVisible: boolean;
  /**
   * The name of the service.
   */
  serviceName: string;
  /**
   * The opening brief sentence introducting the most important aspects of the service.
   */
  serviceLede: string;
  /**
   * The service href that turns the service name into a link.
   */
  serviceHref: string;
  /**
   * The navigation items.
   */
  navigation: any;
  render(): any;
  renderMenuIcon(): any;
  componentDidLoad(): void;
  handleToggleMenu(): void;
}
