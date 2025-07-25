use anyhow::Result;
use crossterm::{
    event::{self, DisableMouseCapture, EnableMouseCapture, Event, KeyCode, KeyEventKind},
    execute,
    terminal::{disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen},
};
use ratatui::{
    backend::CrosstermBackend,
    layout::{Alignment, Constraint, Direction, Layout, Rect},
    style::{Color, Modifier, Style},
    widgets::{
        Block, Borders, Clear, Gauge, List, ListItem, ListState, Paragraph, Wrap,
    },
    Frame, Terminal,
};
use std::io;
use std::path::PathBuf;
use std::fs;

use crate::geometry::{RingParameters, RingType};
use crate::stl_output::{generate_stl_file, validate_for_printing};

#[derive(Debug, Clone)]
pub struct DirectoryBrowser {
    pub current_path: PathBuf,
    pub entries: Vec<PathBuf>,
    pub list_state: ListState,
    pub show_hidden: bool,
}

impl DirectoryBrowser {
    pub fn new(path: PathBuf) -> Result<Self> {
        let mut browser = Self {
            current_path: path.clone(),
            entries: Vec::new(),
            list_state: ListState::default(),
            show_hidden: false,
        };
        browser.refresh_entries()?;
        Ok(browser)
    }

    pub fn refresh_entries(&mut self) -> Result<()> {
        self.entries.clear();
        
        // Add parent directory entry if not at root
        if let Some(parent) = self.current_path.parent() {
            self.entries.push(parent.to_path_buf());
        }
        
        // Read directory entries
        if self.current_path.is_dir() {
            let mut entries: Vec<_> = fs::read_dir(&self.current_path)?
                .filter_map(|entry| entry.ok())
                .map(|entry| entry.path())
                .filter(|path| {
                    if self.show_hidden {
                        true
                    } else {
                        !path.file_name()
                            .and_then(|name| name.to_str())
                            .unwrap_or("")
                            .starts_with('.')
                    }
                })
                .collect();
            
            // Sort: directories first, then files, alphabetically
            entries.sort_by(|a, b| {
                match (a.is_dir(), b.is_dir()) {
                    (true, false) => std::cmp::Ordering::Less,
                    (false, true) => std::cmp::Ordering::Greater,
                    _ => a.file_name().cmp(&b.file_name()),
                }
            });
            
            self.entries.extend(entries);
        }
        
        // Reset selection to first item
        if !self.entries.is_empty() {
            self.list_state.select(Some(0));
        }
        
        Ok(())
    }

    pub fn navigate_to(&mut self, path: PathBuf) -> Result<()> {
        if path.is_dir() {
            self.current_path = path;
            self.refresh_entries()?;
        }
        Ok(())
    }

    pub fn get_selected_path(&self) -> Option<&PathBuf> {
        self.list_state.selected()
            .and_then(|i| self.entries.get(i))
    }

    pub fn move_up(&mut self) {
        let i = match self.list_state.selected() {
            Some(i) => if i == 0 { self.entries.len().saturating_sub(1) } else { i - 1 },
            None => 0,
        };
        self.list_state.select(Some(i));
    }

    pub fn move_down(&mut self) {
        let i = match self.list_state.selected() {
            Some(i) => if i >= self.entries.len().saturating_sub(1) { 0 } else { i + 1 },
            None => 0,
        };
        self.list_state.select(Some(i));
    }
}

#[derive(Debug, Clone, PartialEq)]
pub enum InputField {
    RingType,
    OuterDiameter,
    InnerDiameter,
    OutputDir,
}

#[derive(Debug, Clone)]
pub struct AppState {
    pub ring_type: Option<RingType>,
    pub outer_diameter: String,
    pub inner_diameter: String,
    pub output_dir: String,
    pub current_field: InputField,
    pub ring_type_list_state: ListState,
    pub show_help: bool,
    pub show_preview: bool,
    pub show_directory_browser: bool,
    pub directory_browser: Option<DirectoryBrowser>,
    pub validation_message: Option<String>,
    pub generation_progress: Option<u16>,
    pub generation_complete: bool,
    pub generated_file: Option<String>,
}

impl Default for AppState {
    fn default() -> Self {
        let mut ring_type_list_state = ListState::default();
        ring_type_list_state.select(Some(0));
        
        Self {
            ring_type: None,
            outer_diameter: String::new(),
            inner_diameter: String::new(),
            output_dir: String::from("./"),
            current_field: InputField::RingType,
            ring_type_list_state,
            show_help: false,
            show_preview: false,
            show_directory_browser: false,
            directory_browser: None,
            validation_message: None,
            generation_progress: None,
            generation_complete: false,
            generated_file: None,
        }
    }
}

impl AppState {
    pub fn next_field(&mut self) {
        self.current_field = match self.current_field {
            InputField::RingType => InputField::OuterDiameter,
            InputField::OuterDiameter => InputField::InnerDiameter,
            InputField::InnerDiameter => InputField::OutputDir,
            InputField::OutputDir => InputField::RingType,
        };
        self.validation_message = None;
    }

    pub fn previous_field(&mut self) {
        self.current_field = match self.current_field {
            InputField::RingType => InputField::OutputDir,
            InputField::OuterDiameter => InputField::RingType,
            InputField::InnerDiameter => InputField::OuterDiameter,
            InputField::OutputDir => InputField::InnerDiameter,
        };
        self.validation_message = None;
    }

    pub fn handle_ring_type_input(&mut self, key: KeyCode) {
        match key {
            KeyCode::Up => {
                let i = match self.ring_type_list_state.selected() {
                    Some(i) => if i == 0 { 2 } else { i - 1 },
                    None => 0,
                };
                self.ring_type_list_state.select(Some(i));
            }
            KeyCode::Down => {
                let i = match self.ring_type_list_state.selected() {
                    Some(i) => if i >= 2 { 0 } else { i + 1 },
                    None => 0,
                };
                self.ring_type_list_state.select(Some(i));
            }
            KeyCode::Enter => {
                if let Some(i) = self.ring_type_list_state.selected() {
                    self.ring_type = Some(match i {
                        0 => RingType::Convex,
                        1 => RingType::Concave,
                        2 => RingType::ThreePoint,
                        _ => RingType::Convex,
                    });
                    self.next_field();
                }
            }
            _ => {}
        }
    }

    pub fn handle_text_input(&mut self, c: char) {
        match self.current_field {
            InputField::OuterDiameter => {
                if c.is_ascii_digit() || c == '.' {
                    self.outer_diameter.push(c);
                }
            }
            InputField::InnerDiameter => {
                if c.is_ascii_digit() || c == '.' {
                    self.inner_diameter.push(c);
                }
            }
            InputField::OutputDir => {
                self.output_dir.push(c);
            }
            _ => {}
        }
        self.validation_message = None;
    }

    pub fn handle_backspace(&mut self) {
        match self.current_field {
            InputField::OuterDiameter => {
                self.outer_diameter.pop();
            }
            InputField::InnerDiameter => {
                self.inner_diameter.pop();
            }
            InputField::OutputDir => {
                self.output_dir.pop();
            }
            _ => {}
        }
        self.validation_message = None;
    }

    pub fn validate_and_generate(&mut self) -> Result<()> {
        // Validate inputs
        if self.ring_type.is_none() {
            self.validation_message = Some("Please select a ring type".to_string());
            self.current_field = InputField::RingType;
            return Ok(());
        }

        let outer_diameter: f32 = match self.outer_diameter.parse() {
            Ok(val) => val,
            Err(_) => {
                self.validation_message = Some("Invalid outer diameter".to_string());
                self.current_field = InputField::OuterDiameter;
                return Ok(());
            }
        };

        let inner_diameter: f32 = match self.inner_diameter.parse() {
            Ok(val) => val,
            Err(_) => {
                self.validation_message = Some("Invalid inner diameter".to_string());
                self.current_field = InputField::InnerDiameter;
                return Ok(());
            }
        };

        // Create ring parameters
        let params = match RingParameters::new(self.ring_type.unwrap(), outer_diameter, inner_diameter) {
            Ok(params) => params,
            Err(e) => {
                self.validation_message = Some(format!("Validation error: {}", e));
                return Ok(());
            }
        };

        // Validate for 3D printing
        if let Err(e) = validate_for_printing(&params) {
            self.validation_message = Some(format!("3D printing validation: {}", e));
            return Ok(());
        }

        // Generate STL file
        self.generation_progress = Some(0);
        
        // Simulate progress (in real implementation, this would be integrated into the generation process)
        for i in 0..=100 {
            self.generation_progress = Some(i);
            if i == 100 {
                break;
            }
        }

        let output_dir = if self.output_dir.trim().is_empty() {
            None
        } else {
            Some(self.output_dir.trim())
        };

        match generate_stl_file(&params, output_dir) {
            Ok(file_path) => {
                self.generated_file = Some(file_path);
                self.generation_complete = true;
                self.generation_progress = None;
            }
            Err(e) => {
                self.validation_message = Some(format!("Generation error: {}", e));
                self.generation_progress = None;
            }
        }

        Ok(())
    }

    pub fn open_directory_browser(&mut self) -> Result<()> {
        let current_dir = if self.output_dir.is_empty() || self.output_dir == "./" {
            std::env::current_dir()?
        } else {
            PathBuf::from(&self.output_dir)
        };
        
        self.directory_browser = Some(DirectoryBrowser::new(current_dir)?);
        self.show_directory_browser = true;
        Ok(())
    }

    pub fn close_directory_browser(&mut self) {
        self.show_directory_browser = false;
        self.directory_browser = None;
    }

    pub fn handle_directory_browser_input(&mut self, key: KeyCode) -> Result<()> {
        if let Some(ref mut browser) = self.directory_browser {
            match key {
                KeyCode::Up => browser.move_up(),
                KeyCode::Down => browser.move_down(),
                KeyCode::Enter => {
                    if let Some(selected_path) = browser.get_selected_path().cloned() {
                        if selected_path.is_dir() {
                            browser.navigate_to(selected_path)?;
                        } else if let Some(parent) = selected_path.parent() {
                            // If it's a file, navigate to its parent directory
                            browser.navigate_to(parent.to_path_buf())?;
                        }
                    }
                }
                KeyCode::Char(' ') => {
                    // Select current directory
                    self.output_dir = browser.current_path.to_string_lossy().to_string();
                    self.close_directory_browser();
                }
                KeyCode::Char('h') => {
                    browser.show_hidden = !browser.show_hidden;
                    browser.refresh_entries()?;
                }
                KeyCode::Esc => {
                    self.close_directory_browser();
                }
                _ => {}
            }
        }
        Ok(())
    }

    pub fn reset(&mut self) {
        *self = AppState::default();
    }
}

pub fn run_ui() -> Result<()> {
    // Setup terminal
    enable_raw_mode()?;
    let mut stdout = io::stdout();
    execute!(stdout, EnterAlternateScreen, EnableMouseCapture)?;
    let backend = CrosstermBackend::new(stdout);
    let mut terminal = Terminal::new(backend)?;

    // Create app state
    let mut app_state = AppState::default();
    let mut should_quit = false;

    // Main loop
    while !should_quit {
        terminal.draw(|f| ui(f, &mut app_state))?;

        if let Event::Key(key) = event::read()? {
            if key.kind == KeyEventKind::Press {
                // Handle directory browser input first if it's open
                if app_state.show_directory_browser {
                    let _ = app_state.handle_directory_browser_input(key.code);
                } else {
                    match key.code {
                        KeyCode::Char('q') => should_quit = true,
                        KeyCode::Char('h') => app_state.show_help = !app_state.show_help,
                        KeyCode::Char('p') => app_state.show_preview = !app_state.show_preview,
                        KeyCode::F(1) => app_state.show_help = !app_state.show_help,
                        KeyCode::F(3) => {
                            if app_state.current_field == InputField::OutputDir {
                                let _ = app_state.open_directory_browser();
                            }
                        }
                        KeyCode::Tab => app_state.next_field(),
                        KeyCode::BackTab => app_state.previous_field(),
                        KeyCode::Enter => {
                            match app_state.current_field {
                                InputField::RingType => app_state.handle_ring_type_input(key.code),
                                _ => {
                                    if app_state.generation_complete {
                                        app_state.reset();
                                    } else if app_state.ring_type.is_some() 
                                        && !app_state.outer_diameter.is_empty() 
                                        && !app_state.inner_diameter.is_empty() {
                                        let _ = app_state.validate_and_generate();
                                    }
                                }
                            }
                        }
                        KeyCode::Esc => {
                            if app_state.show_help || app_state.show_preview {
                                app_state.show_help = false;
                                app_state.show_preview = false;
                            } else if app_state.generation_complete {
                                app_state.reset();
                            } else {
                                should_quit = true;
                            }
                        }
                        KeyCode::Backspace => app_state.handle_backspace(),
                        KeyCode::Up | KeyCode::Down => {
                            if app_state.current_field == InputField::RingType {
                                app_state.handle_ring_type_input(key.code);
                            }
                        }
                        KeyCode::Char(c) => {
                            if app_state.current_field != InputField::RingType {
                                app_state.handle_text_input(c);
                            }
                        }
                        _ => {}
                    }
                }
            }
        }
    }

    // Restore terminal
    disable_raw_mode()?;
    execute!(
        terminal.backend_mut(),
        LeaveAlternateScreen,
        DisableMouseCapture
    )?;
    terminal.show_cursor()?;

    Ok(())
}

fn ui(f: &mut Frame, app: &mut AppState) {
    let size = f.size();

    // Main layout
    let chunks = Layout::default()
        .direction(Direction::Vertical)
        .constraints([
            Constraint::Length(3),  // Title
            Constraint::Min(10),    // Main content
            Constraint::Length(3),  // Status bar
        ])
        .split(size);

    // Title
    let title = Paragraph::new("🔬 Optics Ring Generator")
        .style(Style::default().fg(Color::Cyan).add_modifier(Modifier::BOLD))
        .alignment(Alignment::Center)
        .block(Block::default().borders(Borders::ALL).style(Style::default().fg(Color::Blue)));
    f.render_widget(title, chunks[0]);

    // Main content area
    let main_chunks = Layout::default()
        .direction(Direction::Horizontal)
        .constraints([Constraint::Percentage(50), Constraint::Percentage(50)])
        .split(chunks[1]);

    // Left panel - Input form
    render_input_form(f, app, main_chunks[0]);

    // Right panel - Preview/Info
    render_info_panel(f, app, main_chunks[1]);

    // Status bar
    render_status_bar(f, app, chunks[2]);

    // Overlays
    if app.show_help {
        render_help_popup(f, size);
    }

    if app.generation_progress.is_some() {
        render_progress_popup(f, app, size);
    }

    if app.show_directory_browser {
        render_directory_browser(f, app, size);
    }
}

fn render_input_form(f: &mut Frame, app: &AppState, area: Rect) {
    let block = Block::default()
        .title("Configuration")
        .borders(Borders::ALL)
        .style(Style::default().fg(Color::Green));

    let inner = block.inner(area);
    f.render_widget(block, area);

    let chunks = Layout::default()
        .direction(Direction::Vertical)
        .constraints([
            Constraint::Length(6),  // Ring type
            Constraint::Length(3),  // Outer diameter
            Constraint::Length(3),  // Inner diameter
            Constraint::Length(3),  // Output directory
            Constraint::Min(1),     // Spacing
        ])
        .split(inner);

    // Ring Type Selection
    let ring_types = vec![
        ListItem::new("🔲 Convex (CX) - Curves inward toward lens"),
        ListItem::new("🔳 Concave (CC) - Curves outward from lens"),
        ListItem::new("⚡ Three-Point (3P) - Minimal contact points"),
    ];

    let ring_type_style = if app.current_field == InputField::RingType {
        Style::default().fg(Color::Yellow).add_modifier(Modifier::BOLD)
    } else {
        Style::default()
    };

    let ring_type_list = List::new(ring_types)
        .block(Block::default()
            .title("Ring Type")
            .borders(Borders::ALL)
            .style(ring_type_style))
        .highlight_style(Style::default().bg(Color::DarkGray).add_modifier(Modifier::BOLD))
        .highlight_symbol("→ ");

    f.render_stateful_widget(ring_type_list, chunks[0], &mut app.ring_type_list_state.clone());

    // Outer Diameter Input
    let outer_diameter_style = if app.current_field == InputField::OuterDiameter {
        Style::default().fg(Color::Yellow).add_modifier(Modifier::BOLD)
    } else {
        Style::default()
    };

    let outer_diameter_input = Paragraph::new(app.outer_diameter.as_str())
        .style(Style::default().fg(Color::White))
        .block(Block::default()
            .title("Outer Diameter (mm)")
            .borders(Borders::ALL)
            .style(outer_diameter_style));
    f.render_widget(outer_diameter_input, chunks[1]);

    // Inner Diameter Input
    let inner_diameter_style = if app.current_field == InputField::InnerDiameter {
        Style::default().fg(Color::Yellow).add_modifier(Modifier::BOLD)
    } else {
        Style::default()
    };

    let inner_diameter_input = Paragraph::new(app.inner_diameter.as_str())
        .style(Style::default().fg(Color::White))
        .block(Block::default()
            .title("Inner Diameter (mm)")
            .borders(Borders::ALL)
            .style(inner_diameter_style));
    f.render_widget(inner_diameter_input, chunks[2]);

    // Output Directory Input
    let output_dir_style = if app.current_field == InputField::OutputDir {
        Style::default().fg(Color::Yellow).add_modifier(Modifier::BOLD)
    } else {
        Style::default()
    };

    let output_dir_input = Paragraph::new(app.output_dir.as_str())
        .style(Style::default().fg(Color::White))
        .block(Block::default()
            .title("Output Directory")
            .borders(Borders::ALL)
            .style(output_dir_style));
    f.render_widget(output_dir_input, chunks[3]);
}

fn render_info_panel(f: &mut Frame, app: &AppState, area: Rect) {
    if app.generation_complete {
        render_success_panel(f, app, area);
    } else if let Some(ref msg) = app.validation_message {
        render_validation_panel(f, msg, area);
    } else {
        render_preview_panel(f, app, area);
    }
}

fn render_success_panel(f: &mut Frame, app: &AppState, area: Rect) {
    let success_text = if let Some(ref file) = app.generated_file {
        format!("✅ Success!\n\nSTL file generated:\n{}\n\nPress Enter to create another ring\nPress Esc to start over\nPress 'q' to quit", file)
    } else {
        "✅ Generation complete!".to_string()
    };

    let success_panel = Paragraph::new(success_text)
        .style(Style::default().fg(Color::Green))
        .alignment(Alignment::Center)
        .wrap(Wrap { trim: true })
        .block(Block::default()
            .title("Complete")
            .borders(Borders::ALL)
            .style(Style::default().fg(Color::Green)));

    f.render_widget(success_panel, area);
}

fn render_validation_panel(f: &mut Frame, message: &str, area: Rect) {
    let validation_panel = Paragraph::new(format!("⚠️  {}", message))
        .style(Style::default().fg(Color::Red))
        .alignment(Alignment::Center)
        .wrap(Wrap { trim: true })
        .block(Block::default()
            .title("Validation Error")
            .borders(Borders::ALL)
            .style(Style::default().fg(Color::Red)));

    f.render_widget(validation_panel, area);
}

fn render_preview_panel(f: &mut Frame, app: &AppState, area: Rect) {
    let mut preview_text = String::from("📋 Preview\n\n");
    
    if let Some(ring_type) = app.ring_type {
        preview_text.push_str(&format!("Type: {} ({})\n", ring_type, match ring_type {
            RingType::Convex => "Convex",
            RingType::Concave => "Concave",
            RingType::ThreePoint => "Three-point",
        }));
    } else {
        preview_text.push_str("Type: Not selected\n");
    }

    if !app.outer_diameter.is_empty() {
        preview_text.push_str(&format!("Outer ⌀: {}mm\n", app.outer_diameter));
    } else {
        preview_text.push_str("Outer ⌀: Not set\n");
    }

    if !app.inner_diameter.is_empty() {
        preview_text.push_str(&format!("Inner ⌀: {}mm\n", app.inner_diameter));
    } else {
        preview_text.push_str("Inner ⌀: Not set\n");
    }

    // Calculate wall thickness if both diameters are provided
    if !app.outer_diameter.is_empty() && !app.inner_diameter.is_empty() {
        if let (Ok(outer), Ok(inner)) = (app.outer_diameter.parse::<f32>(), app.inner_diameter.parse::<f32>()) {
            let wall_thickness = (outer - inner) / 2.0;
            preview_text.push_str(&format!("Wall thickness: {:.1}mm\n", wall_thickness));
            
            if let Some(ring_type) = app.ring_type {
                let filename = format!("{}-{}.stl", ring_type, inner);
                preview_text.push_str(&format!("\nOutput file: {}", filename));
            }
        }
    }

    preview_text.push_str("\n\nPress Enter to generate when ready");

    let preview_panel = Paragraph::new(preview_text)
        .style(Style::default().fg(Color::Cyan))
        .wrap(Wrap { trim: true })
        .block(Block::default()
            .title("Preview")
            .borders(Borders::ALL)
            .style(Style::default().fg(Color::Cyan)));

    f.render_widget(preview_panel, area);
}

fn render_status_bar(f: &mut Frame, app: &AppState, area: Rect) {
    let status_text = if app.current_field == InputField::OutputDir {
        "Tab: Next field | F3: Browse directory | Enter: Generate | F1/h: Help | q: Quit"
    } else {
        "Tab: Next field | Shift+Tab: Previous | Enter: Select/Generate | F1/h: Help | q: Quit"
    };
    
    let status_bar = Paragraph::new(status_text)
        .style(Style::default().fg(Color::White).bg(Color::DarkGray))
        .alignment(Alignment::Center)
        .block(Block::default());

    f.render_widget(status_bar, area);
}

fn render_help_popup(f: &mut Frame, area: Rect) {
    let popup_area = centered_rect(80, 60, area);
    
    let help_text = "🔬 Optics Ring Generator - Help\n\n\
        NAVIGATION:\n\
        • Tab / Shift+Tab - Move between fields\n\
        • Arrow keys - Navigate ring type list\n\
        • Enter - Select option or generate STL\n\
        • Backspace - Delete characters\n\
        • F3 - Open directory browser (when in Output Directory field)\n\
        • Esc - Close dialogs or quit\n\
        • q - Quit application\n\n\
        DIRECTORY BROWSER:\n\
        • Arrow keys - Navigate file/folder list\n\
        • Enter - Enter selected directory\n\
        • Space - Select current directory\n\
        • h - Toggle hidden files\n\
        • Esc - Cancel and close browser\n\n\
        RING TYPES:\n\
        • Convex (CX) - Curves inward, gentle contact\n\
        • Concave (CC) - Curves outward, secure cradle\n\
        • Three-Point (3P) - Minimal contact points\n\n\
        REQUIREMENTS:\n\
        • Outer diameter > Inner diameter\n\
        • Minimum wall thickness: 1.0mm\n\
        • All dimensions in millimeters\n\n\
        Press Esc or F1 to close this help";

    f.render_widget(Clear, popup_area);
    let help_popup = Paragraph::new(help_text)
        .style(Style::default().fg(Color::White))
        .wrap(Wrap { trim: true })
        .block(Block::default()
            .title("Help")
            .borders(Borders::ALL)
            .style(Style::default().fg(Color::Blue)));

    f.render_widget(help_popup, popup_area);
}

fn render_progress_popup(f: &mut Frame, app: &AppState, area: Rect) {
    let popup_area = centered_rect(50, 20, area);
    
    f.render_widget(Clear, popup_area);
    
    let progress_block = Block::default()
        .title("Generating STL...")
        .borders(Borders::ALL)
        .style(Style::default().fg(Color::Green));
    
    let inner = progress_block.inner(popup_area);
    f.render_widget(progress_block, popup_area);
    
    if let Some(progress) = app.generation_progress {
        let gauge = Gauge::default()
            .block(Block::default().borders(Borders::NONE))
            .gauge_style(Style::default().fg(Color::Green))
            .percent(progress)
            .label(format!("{}%", progress));
        
        f.render_widget(gauge, inner);
    }
}

fn centered_rect(percent_x: u16, percent_y: u16, r: Rect) -> Rect {
    let popup_layout = Layout::default()
        .direction(Direction::Vertical)
        .constraints([
            Constraint::Percentage((100 - percent_y) / 2),
            Constraint::Percentage(percent_y),
            Constraint::Percentage((100 - percent_y) / 2),
        ])
        .split(r);

    Layout::default()
        .direction(Direction::Horizontal)
        .constraints([
            Constraint::Percentage((100 - percent_x) / 2),
            Constraint::Percentage(percent_x),
            Constraint::Percentage((100 - percent_x) / 2),
        ])
        .split(popup_layout[1])[1]
}

fn render_directory_browser(f: &mut Frame, app: &AppState, area: Rect) {
    if let Some(ref browser) = app.directory_browser {
        // Create popup area (80% of screen)
        let popup_area = centered_rect(80, 80, area);
        
        // Clear the area
        f.render_widget(Clear, popup_area);
        
        // Main block
        let block = Block::default()
            .title(format!(" Directory Browser - {} ", browser.current_path.display()))
            .borders(Borders::ALL)
            .style(Style::default().fg(Color::Yellow));
        
        let inner_area = block.inner(popup_area);
        f.render_widget(block, popup_area);
        
        // Split into directory list and help text
        let chunks = Layout::default()
            .direction(Direction::Vertical)
            .constraints([
                Constraint::Min(10),  // Directory list
                Constraint::Length(4), // Help text
            ])
            .split(inner_area);
        
        // Directory list
        let items: Vec<ListItem> = browser.entries.iter().enumerate().map(|(i, path)| {
            let display_name = if i == 0 && path.parent().is_some() {
                ".. (parent directory)".to_string()
            } else {
                let name = path.file_name()
                    .and_then(|n| n.to_str())
                    .unwrap_or("<invalid>")
                    .to_string();
                if path.is_dir() {
                    format!("📁 {}/", name)
                } else {
                    format!("📄 {}", name)
                }
            };
            
            ListItem::new(display_name)
        }).collect();
        
        let list = List::new(items)
            .block(Block::default().borders(Borders::ALL).title("Contents"))
            .highlight_style(Style::default().fg(Color::Black).bg(Color::Yellow))
            .highlight_symbol("▶ ");
        
        let mut list_state = browser.list_state.clone();
        f.render_stateful_widget(list, chunks[0], &mut list_state);
        
        // Help text
        let help_text = format!(
            "Navigation: ↑/↓ to select, Enter to enter directory, Space to select current directory\n\
             Options: h to toggle hidden files, Esc to cancel\n\
             Current selection will be saved to: {}", 
            browser.current_path.display()
        );
        
        let help = Paragraph::new(help_text)
            .block(Block::default().borders(Borders::ALL).title("Help"))
            .style(Style::default().fg(Color::Gray))
            .wrap(Wrap { trim: true });
        
        f.render_widget(help, chunks[1]);
    }
}
