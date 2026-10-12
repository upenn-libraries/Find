import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = [
        'select',
        'coverage'
    ];


    connect() {
        const url = this.selectTarget.selectedOptions[0].value
        const coverage = this.selectTarget.selectedOptions[0].text
        this.updateCallToAction(url)
        this.highlightCoverageStatement(coverage)


    }

    selectChanged(event) {
       const url = event.target.selectedOptions[0].value
        const coverage = event.target.selectedOptions[0].text
        this.updateCallToAction(url)
        this.highlightCoverageStatement(coverage)
    }


    highlightCoverageStatement(selectedCoverage) {
        const coverageValues = this.coverageTarget.textContent.split(", ")

        this.coverageTarget.innerHTML = coverageValues.map(value => {
            return value === selectedCoverage ? `<strong>${value}</strong>` : value
        }).join(', ')
}

    updateCallToAction(url) {
        this.selectTarget.nextElementSibling.href = url
    }
}
