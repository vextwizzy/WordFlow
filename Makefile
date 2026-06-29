# WordFlow Makefile
# Convenience commands for development

.PHONY: help setup lint format clean

help:
	@echo "WordFlow - iOS English Learning App"
	@echo ""
	@echo "Available commands:"
	@echo "  make setup    - Setup the project for development"
	@echo "  make lint     - Run SwiftLint"
	@echo "  make format   - Run SwiftFormat"
	@echo "  make clean    - Clean build artifacts"

setup:
	@echo "Setting up WordFlow..."
	@echo "1. Open Xcode 15.0+"
	@echo "2. Create new iOS App project (WordFlow)"
	@echo "3. Set deployment target to iOS 17.0"
	@echo "4. Import all files from the project folder"
	@echo "5. Configure signing & capabilities"
	@echo "6. Add API keys in Utilities/Constants/APIKeys.swift"
	@echo "7. Build and run (Cmd+R)"
	@echo ""
	@echo "See SETUP.md for detailed instructions"

lint:
	@if command -v swiftlint &> /dev/null; then \
		swiftlint --config .swiftlint.yml; \
	else \
		echo "SwiftLint not installed. Install with: brew install swiftlint"; \
	fi

format:
	@if command -v swiftformat &> /dev/null; then \
		swiftformat . --config .swiftformat; \
	else \
		echo "SwiftFormat not installed. Install with: brew install swiftformat"; \
	fi

clean:
	@echo "Cleaning..."
	@rm -rf DerivedData/
	@rm -rf .build/
	@echo "Done!"
